--[[
初步的设想是,有三个关键的变量,其作用和含义分别是：
    self:is_parted()，是否与redis和monitor都失去联系，若true，则理应对此进程做一些限制，比如不能client服务，不能接受其他world迁移过来的数据等；
    self:is_adjusting_version(), 是否world_online_servers版本有变动，正在调整中。若true，则允许接受其他world迁移过来的数据；
    self:_version: 当前正在应用的world_online_servers的版本，若其有变化，则本进程应该做一些数据迁移操作，比如根据一致性哈希判断，不属于本进程的数据迁移到其他world上；
    根据这三个变量，1.实现动态伸缩world的数量时，self:_version变化触发本进程数据转移行为，被转进的进程根据self:is_adjusting_version()==true，和一致性哈希判定，决定是否接纳迁移数据
    2.当本进程与redis和monitor失去联系，那么本进程某些服务将停止服务，尽量保证集群数据正确性
--]]

---@class ServerRoleShadow: ServiceBase
ServerRoleShadow = ServerRoleShadow or class("ServerRoleShadow", ServiceBase)

function ServerRoleShadow:ctor(service_mgr, service_name, zone_name, server_role_name)
    ServerRoleShadow.super.ctor(self, service_mgr, service_name)

    self._zone_name = zone_name
    self._role_name = server_role_name
    self._monitor_setting = ServerRoleMonitorSetting:new(self._zone_name, self._role_name)
    self._rpc_svc_proxy = nil

    self._adjusting_version = -1
    self._adjusting_version_over_sec = 0
    self._version = nil
    self._work_servers = {}
    self._cached_is_adjusting = false

    ---@type RedisClient
    self._redis_client = nil
    self._cached_is_parted = true
    self._monitor_rsp_last_sec = 0
    self._redis_rsp_last_sec = 0
    self._query_monitor_last_sec = 0
    self._query_reids_last_sec = 0

    self._server_hash = ConsistentHash:new()
end

function ServerRoleShadow:_on_init()
    ServerRoleShadow.super:_on_init(self)
    ---@type RedisServerConfig
    local redis_cfg = self.server.redis_setting_work_servers
    self._redis_client = RedisClient:new(redis_cfg.is_cluster, redis_cfg.host, redis_cfg.pwd, redis_cfg.thread_num, redis_cfg.cnn_timeout_ms, redis_cfg.cmd_timeout_ms)
    self._rpc_svc_proxy = self.server.rpc:create_svc_proxy()
end

function ServerRoleShadow:_on_start()
    ServerRoleShadow.super._on_start(self)
    local ret = self._redis_client:start()
    if not ret then
        self._error_num = -1
        self._error_msg = "ServerRoleShadow start redis client fail"
        return
    end
    self._rpc_svc_proxy:set_remote_call_handle_fn(self._monitor_setting.rpc_method_notify_server_data,
            Functional.make_closure(self._on_rpc_notify_work_servers_data, self))
end

function ServerRoleShadow:_on_stop()
    ServerRoleShadow.super._on_stop(self)
    self._redis_client:stop()
    self._rpc_svc_proxy:clear_remote_call()
end

function ServerRoleShadow:_on_release()
    ServerRoleShadow.super._on_release(self)
end

function ServerRoleShadow:_on_update()
    ServerRoleShadow.super._on_update(self)

    local is_joined_cluster = self.server:is_joined_cluster()
    local now_sec = logic_sec()
    if is_joined_cluster and now_sec >= self._query_monitor_last_sec + 3 then
        self._query_monitor_last_sec = now_sec
        self:_query_monitor(true)
    end
    if is_joined_cluster and now_sec >= self._query_reids_last_sec + 3 then
        self._query_reids_last_sec = now_sec
        self:_query_redis()
    end

    self:_check_is_parted_change()
    self:_check_adjust_version()

    -- log_print("ServerRoleShadow:_on_update ", self:is_parted(), self._version, self:is_adjusting_version())
end

---@param rsp RpcRsp
function ServerRoleShadow:_on_rpc_notify_work_servers_data(rsp, msg)
    rsp:response()

    self._monitor_rsp_last_sec = logic_sec()

    -- log_print("ServerRoleShadow:_on_rpc_notify_work_servers_data", self._version, msg)
    if is_number(msg.version) then
        if is_number(msg.lead_rehash_left_sec) then
            self:_set_adjusting_version(msg.version, msg.lead_rehash_left_sec)
        end
        if not self._version or msg.version > self._version then
            if nil == msg.servers then
                self:_query_monitor(false)
            else
                self:_set_work_servers(msg.version, msg.servers)
            end
        end
    end
end

function ServerRoleShadow:_query_monitor(is_simple_info)
    local server_key = self.server.peer_net:random_server_key(Server_Role.World_Sentinel)
    if server_key then
        self.server.rpc:call(function(rpc_error_num)
            if Error_None == rpc_error_num then
                self._monitor_rsp_last_sec = logic_sec()
            end
        end, server_key, self._monitor_setting.rpc_method_query_server_data, is_simple_info)
    end
end

function ServerRoleShadow:_query_redis()
    self._redis_client:command(1, function(ret)
        if Error_None ~= ret:get_error() then
        else
            self._redis_rsp_last_sec = logic_sec()
            local adjusting_version = ret:get_reply():get_number()
            if adjusting_version then
                if not self._adjusting_version or adjusting_version > self._adjusting_version then
                    self:_set_adjusting_version(adjusting_version, self._monitor_setting.lead_world_rehash_duration_sec)
                end
            end
        end
    end, "get " .. self._monitor_setting.redis_key_adjusting_version)

    self._redis_client:command(1, function(ret)
        if Error_None ~= ret:get_error() then

        else
            self._redis_rsp_last_sec = logic_sec()
            if not ret:get_reply():get_error() then
                local reply_array = ret:get_reply():get_array()
                if reply_array and #reply_array >= 1 then
                    local version = reply_array[1]:get_number()
                    if version then
                        if not self._version or version > self._version then
                            table.remove(reply_array, 1)
                            local work_servers = {}
                            for _, v in pairs(reply_array) do
                                work_servers[v:get_str()] = true
                            end
                            self:_set_work_servers(version, work_servers)
                        end
                    end
                end
            end
        end
    end, "LRANGE %s 0 -1", self._monitor_setting.redis_key_servers)
end

function ServerRoleShadow:_set_adjusting_version(version, left_sec)
    self._adjusting_version = version
    self._adjusting_version_over_sec = logic_sec() + left_sec
    -- log_print("ServerRoleShadow:_set_adjusting_version ", self._adjusting_version, self._adjusting_version_over_sec)
    self:_check_adjust_version()
end

function ServerRoleShadow:_set_work_servers(version, servers)
    if not is_number(version) or not is_table(servers) then
        return
    end
    if self._version and version == self._version then
        return
    end

    local old_work_servers = self._work_servers
    self._version = version
    self._work_servers = servers
    -- log_print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! _set_work_servers", version, servers)

    local is_changed = false
    for new_k, _ in pairs(self._work_servers) do
        if not old_work_servers[new_k] then
            self._server_hash:upsert_node(new_k)
            is_changed = true
        end
    end
    for old_k, _ in pairs(old_work_servers) do
        if not self._work_servers[old_k] then
            is_changed = true
            self._server_hash:delete_node(old_k)
        end
    end

    self:fire(self._monitor_setting.event_version_change, self._version)
    self:_check_adjust_version()

    --for i=1, 100 do
    --    log_print("consistent_hash ret is ", i, self:find_available_server_address(i))
    --end
end

function ServerRoleShadow:is_parted()
    return self._cached_is_parted
end

function ServerRoleShadow:_check_is_parted_change()
    local ret = true
    local now_sec = logic_sec()
    if now_sec - self._monitor_rsp_last_sec <= self._monitor_setting.parted_with_monitor_with_no_communication then
        ret = false
    end
    if now_sec - self._redis_rsp_last_sec <= self._monitor_setting.parted_with_redis_with_no_communication then
        ret = false
    end
    if ret ~= self._cached_is_parted then
        log_print("ServerRoleShadow:_check_is_parted_change ", ret, self._cached_is_parted)
        self._cached_is_parted = ret
        self:fire(self._monitor_setting.event_shadow_parted_state_change, self._cached_is_parted)
    end
end

function ServerRoleShadow:is_adjusting_version()
    return self._cached_is_adjusting
end

function ServerRoleShadow:_check_adjust_version()
    local now_sec = logic_sec()
    local is_adjusting = false
    if self._adjusting_version and now_sec <= self._adjusting_version_over_sec then
        if self._version == self._adjusting_version then
            is_adjusting = true
        end
    end
    if is_adjusting ~= self._cached_is_adjusting then
        log_print("ServerRoleShadow:_check_adjust_version", self._cached_is_parted, is_adjusting, self._cached_is_adjusting, self._version, self._adjusting_version)
        self._cached_is_adjusting = is_adjusting
        self:fire(self._monitor_setting.event_adjusting_version_state_change, self._cached_is_adjusting)
    end
end

function ServerRoleShadow:cal_server_address(val)
    local is_find, selected_world_key = self._server_hash:find_address(val)
    return is_find and selected_world_key or nil
end

function ServerRoleShadow:find_available_server_address(val)
    local error_num = Error_None
    local selected_world_key = nil
    repeat
        if self:is_parted() then
            error_num = Error_Server_Role_Shadow_Parted
            break
        end
        if self:is_adjusting_version() then
            error_num = Error_Consistent_Hash_Adjusting
            break
        end
        local is_find = false
        is_find, selected_world_key = self._server_hash:find_address(val)
        if not is_find then
            error_num = Error_Not_Available_Server
            break
        end
        if not self.server.peer_net:is_server_available(selected_world_key) then
            error_num = Error_Not_Available_Server
            break
        end
    until true
    return error_num, selected_world_key
end

function ServerRoleShadow:get_version()
    return self._version
end

---@return ServerRoleMonitorSetting
function ServerRoleShadow:get_settting()
    return self._monitor_setting
end