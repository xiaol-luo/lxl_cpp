---@class OnlineWorldShadow: ServiceBase
OnlineWorldShadow = OnlineWorldShadow or class("OnlineWorldShadow", ServiceBase)

function OnlineWorldShadow:ctor(service_mgr, service_name)
    OnlineWorldShadow.super.ctor(self, service_mgr, service_name)

    self._adjusting_version = -1
    self._adjusting_version_over_sec = 0
    self._version = nil
    self._online_world_servers = {}

    self._working_adjusting_version = nil
    self._working_adjusting_version_over_sec = nil

    ---@type RedisClient
    self._redis_client = nil
    self._cached_is_parted = true
    self._world_monitor_rsp_last_sec = 0
    self._redis_rsp_last_sec = 0
    self._query_online_world_monitor_last_sec = 0
    self._query_online_world_reids_last_sec = 0

    self._redis_key_online_world_adjusting_version = string.format(Online_World_Const.redis_key_online_world_adjusting_version_format, self.server.zone)
    self._redis_key_online_world_version = string.format(Online_World_Const.redis_key_online_world_version_format, self.server.zone)
    self._redis_key_online_world_servers = string.format(Online_World_Const.redis_key_online_world_servers_format, self.server.zone)

    self._server_hash = ConsistentHash:new()
end

function OnlineWorldShadow:_on_init()
    OnlineWorldShadow.super:_on_init(self)
    ---@type RedisServerConfig
    local redis_cfg = self.server.redis_online_servers_setting
    self._redis_client = RedisClient:new(redis_cfg.is_cluster, redis_cfg.host, redis_cfg.pwd, redis_cfg.thread_num, redis_cfg.cnn_timeout_ms, redis_cfg.cmd_timeout_ms)
end

function OnlineWorldShadow:_on_start()
    OnlineWorldShadow.super._on_start(self)
    local ret = self._redis_client:start()
    if not ret then
        self._error_num = -1
        self._error_msg = "OnlineWorldShadow start redis client fail"
        return
    end
    self.server.rpc:set_remote_call_handle_fn(Online_World_Rpc_Method.notify_online_world_servers_data,
            Functional.make_closure(self._on_rpc_notify_online_world_servers_data, self))
end

function OnlineWorldShadow:_on_stop()
    OnlineWorldShadow.super._on_stop(self)
    self._redis_client:stop()
    self.server.rpc:set_remote_call_handle_fn(Online_World_Rpc_Method.notify_online_world_servers_data, nil)
end

function OnlineWorldShadow:_on_release()
    OnlineWorldShadow.super._on_release(self)
end

function OnlineWorldShadow:_on_update()
    OnlineWorldShadow.super._on_update(self)

    local is_joined_cluster = self.server.discovery:is_joined_cluster()
    local now_sec = logic_sec()
    if is_joined_cluster and now_sec >= self._query_online_world_monitor_last_sec + 3 then
        self._query_online_world_monitor_last_sec = now_sec
        self:_query_online_world_monitor(true)
    end
    if is_joined_cluster and now_sec >= self._query_online_world_reids_last_sec + 3 then
        self._query_online_world_reids_last_sec = now_sec
        self:_query_online_world_redis()
    end

    self:_check_is_parted_change()
    self:_check_adjust_version()
end

---@param rsp RpcRsp
function OnlineWorldShadow:_on_rpc_notify_online_world_servers_data(rsp, msg)
    rsp:respone()

    self._world_monitor_rsp_last_sec = logic_sec()

    if is_number(msg.version) then
        if is_number(msg.lead_rehash_left_sec) then
            self:_set_adjusting_version(msg.version, msg.lead_rehash_left_sec)
        end
        local need_detail_info = false
        if not self._version or msg.version > self._version then
            need_detail_info = not msg.servers
        end
        if need_detail_info then
            self:_query_online_world_monitor(false)
        else
            self:_set_online_world_servers(msg.version, msg.servers)
        end
    end
end

function OnlineWorldShadow:_query_online_world_monitor(is_simple_info)
    local server_key = self.server.peer_net:rand_role_server_key(Server_Role.World_Sentinel)
    if server_key then
        self.server.rpc:call(function(rpc_error_num)
            if Error_None == rpc_error_num then
                self._world_monitor_rsp_last_sec = logic_sec()
            end
        end, server_key, Online_World_Rpc_Method.query_online_world_servers_data, is_simple_info)
    end
end

function OnlineWorldShadow:_query_online_world_redis()
    self._redis_client:command(1, function(ret)
        if Error_None ~= ret:get_error() then
        else
            self._redis_rsp_last_sec = logic_sec()
            local adjusting_version = ret:get_reply():get_number()
            if adjusting_version then
                if not self._adjusting_version or adjusting_version > self._adjusting_version then
                    self:_set_adjusting_version(adjusting_version, Online_World_Const.LEAD_WORLD_REHASH_DURATION_SEC)
                end
            end
        end
    end, "get " .. self._redis_key_online_world_adjusting_version)

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
                            local online_world_servers = {}
                            for _, v in pairs(reply_array) do
                                online_world_servers[v:get_str()] = true
                            end
                            self:_set_online_world_servers(version, online_world_servers)
                        end
                    end
                end
            end
        end
    end, "LRANGE %s 0 -1", self._redis_key_online_world_servers)
end

function OnlineWorldShadow:_set_adjusting_version(version, left_sec)
    local old_version = self._adjusting_version
    self._adjusting_version = version
    self._adjusting_version_over_sec = logic_sec() + left_sec
    if self._adjusting_version_over_sec == self._working_adjusting_version then
        self._working_adjusting_version_over_sec = self._adjusting_version_over_sec
    end
    -- log_print("OnlineWorldShadow:_set_adjusting_version ", self._adjusting_version, self._adjusting_version_over_sec)
    self:_check_adjust_version()
end

function OnlineWorldShadow:_set_online_world_servers(version, servers)
    if not is_number(version) then
        return
    end
    if self._version and version <= self._version then
        return
    end
    local old_version = self._version
    local old_online_world_servers = self._online_world_servers
    self._version = version
    self._online_world_servers = servers
    -- log_print("OnlineWorldShadow:_set_online_world_servers ", self._adjusting_version, self._version, self._online_world_servers)
    -- 马上就应用了
    for new_k, _ in pairs(self._online_world_servers) do
        if not old_online_world_servers[new_k] then
            self._server_hash:upsert_node(new_k)
        end
    end
    for old_k, _ in pairs(old_online_world_servers) do
        if not self._online_world_servers[old_k] then
            self._server_hash:delete_node(old_k)
        end
    end

    --for i=1, 100 do
    --    log_print("consistent_hash ret is ", i, self:find_server_address(i))
    --end

    self:_check_adjust_version()
end

function OnlineWorldShadow:is_parted()
    return self._cached_is_parted
end

function OnlineWorldShadow:_check_is_parted_change()
    local ret = true
    local now_sec = logic_sec()
    if now_sec - self._world_monitor_rsp_last_sec <= Online_World_Const.Parted_With_Monitor_With_No_Communication then
        ret = false
    end
    if now_sec - self._redis_rsp_last_sec <= Online_World_Const.Parted_With_Redis_With_No_Communication then
        ret = false
    end
    if ret ~= self._cached_is_parted then
        -- todo:
    end
    self._cached_is_parted = ret
end

function OnlineWorldShadow:get_working_adjusting_version()
    return self._working_adjusting_version
end

function OnlineWorldShadow:is_adjusting_version()
    return nil ~= self._working_adjusting_version
end

function OnlineWorldShadow:_check_adjust_version()
    local now_sec = logic_sec()
    if self._working_adjusting_version then
        if now_sec > self._working_adjusting_version_over_sec then
            self:_stop_adjusting()
        end
    end

    local need_adjust = false
    if self._adjusting_version and now_sec <= self._adjusting_version_over_sec then
        if self._version == self._adjusting_version then
            need_adjust = true
        end
    end
    if need_adjust then
        if not self._working_adjusting_version or self._adjusting_version > self._working_adjusting_version then
            self:_start_adjusting()
        end
    end
    -- log_print("OnlineWorldShadow:_check_adjust_version ", need_adjust, self._working_adjusting_version, self._working_adjusting_version_over_sec)
end

function OnlineWorldShadow:_start_adjusting()
    self:_stop_adjusting()
    self._working_adjusting_version = self._adjusting_version
    self._working_adjusting_version_over_sec = self._adjusting_version_over_sec
    -- todo: -- 派发事件
    log_print("OnlineWorldMonitor:_start_adjusting")
end

function OnlineWorldShadow:_stop_adjusting()
    if self._working_adjusting_version then
        -- todo: -- 派发事件
        self._working_adjusting_version = nil
        self._working_adjusting_version_over_sec = nil
        log_print("OnlineWorldMonitor:_stop_adjusting")
    end
end

function OnlineWorldShadow:find_server_address(val)
    local is_find, addr = self._server_hash:find_address(val)
    if is_find then
        return addr
    else
        return nil
    end
end


