
local Logic_State = {
    free = "free",
    reset_all = "reset_all",
    wait_join_cluster = "wait_join_cluster",
    joined_cluster = "joined_cluster",
    pull_persistent_data = "pull_persistent_data",
    diff_online_server_data = "diff_online_server_data",
    persist_online_server_data = "persist_online_server_data",
    lead_world_rehash = "lead_world_rehash",
    guarantee_data_valid = "guarantee_data_valid",
    released = "released",
}

local Opera_Name = {
    query_db_version = "query_db_version",
    query_db_adjusting_version = "query_db_adjusting_version",
    query_db_online_servers = "query_db_online_servers",

    set_db_version = "set_db_version",
    set_db_adjusting_version = "set_db_adjusting_version",
    set_db_online_servers = "set_db_online_servers",
}

local Opera_State = {
    free = "free",
    acting = "acting",
    success = "success",
    fail = "fail",
}

---@class OnlineWorldMonitor: ServiceBase
OnlineWorldMonitor = OnlineWorldMonitor or class("OnlineWorldMonitor", ServiceBase)

function OnlineWorldMonitor:ctor(service_mgr, service_name)
    OnlineWorldMonitor.super.ctor(self, service_mgr, service_name)
    self._redis_key_world_online_adjusting_version = string.format(World_Online_Const.redis_key_world_online_adjusting_version_format, self.server.zone_name)
    self._redis_key_world_online_version = string.format(World_Online_Const.redis_key_world_online_version_format, self.server.zone_name)
    self._redis_key_world_online_servers = string.format(World_Online_Const.redis_key_world_online_servers_format, self.server.zone_name)

    log_print("self._redis_key_world_online_adjusting_version", self._redis_key_world_online_adjusting_version)
    log_print("self._redis_key_world_online_version", self._redis_key_world_online_version)
    log_print("self._redis_key_world_online_servers", self._redis_key_world_online_servers)

    ---@type RedisClient
    self._redis_client = nil
    self._zone_setting = self.server.zone_setting

    self._curr_logic_state = Logic_State.free
    self._has_pulled_from_db = false
    self._world_online_servers = {}
    self._version = nil
    self._adjusting_version = nil
    self._opera_states = {}

    self._adjusting_world_online_servers = nil
    self._lead_world_rehash_state_over_sec = nil
    self._guarantee_data_valid_over_sec = 0
    self._last_tick_logic_sec = 0
    self._is_never_lead_rehash = true
end

function OnlineWorldMonitor:_on_init()
    OnlineWorldMonitor.super:_on_init(self)
    ---@type RedisServerConfig
    local redis_cfg = self.server.redis_setting_online_servers
    self._redis_client = RedisClient:new(redis_cfg.is_cluster, redis_cfg.host, redis_cfg.pwd, redis_cfg.thread_num, redis_cfg.cnn_timeout_ms, redis_cfg.cmd_timeout_ms)
end

function OnlineWorldMonitor:_on_start()
    OnlineWorldMonitor.super._on_start(self)
    local ret = self._redis_client:start()
    if not ret then
        self._error_num = -1
        self._error_msg = "OnlineWorldMonitor start redis client fail"
        return
    end

    self.server.rpc:set_remote_call_handle_fn(World_Online_Rpc_Method.query_world_online_servers_data,
            Functional.make_closure(self._on_rpc_query_world_online_servers_data, self))

    self:_set_logic_state(Logic_State.reset_all)
end

function OnlineWorldMonitor:_on_stop()
    OnlineWorldMonitor.super._on_stop(self)
    self._redis_client:stop()
    self.server.rpc:set_remote_call_handle_fn(World_Online_Rpc_Method.query_world_online_servers_data, nil)
end

function OnlineWorldMonitor:_on_release()
    OnlineWorldMonitor.super._on_release(self)
    self._curr_logic_state = Logic_State.released
end

function OnlineWorldMonitor:_on_update()
    OnlineWorldMonitor.super._on_update(self)
    self:_tick_logic()
end

function OnlineWorldMonitor:_tick_logic()
    if not self.server.discovery:is_joined_cluster() then
        return
    end

    local now_sec = logic_sec()
    if now_sec - self._last_tick_logic_sec < 1 then
        return
    end

    self._last_tick_logic_sec = now_sec

    if Logic_State.reset_all == self._curr_logic_state then
        self:_reset_datas()
        self:_set_logic_state(Logic_State.wait_join_cluster)
    end

    if Logic_State.wait_join_cluster == self._curr_logic_state then
        if self.server.discovery:is_joined_cluster() then
            self:_set_logic_state(Logic_State.joined_cluster)
        end
    end

    if Logic_State.joined_cluster == self._curr_logic_state then
        self:_set_logic_state(Logic_State.pull_persistent_data)
    end

    if Logic_State.pull_persistent_data == self._curr_logic_state then
        local is_all_done = self:_check_query_db_logic()
        if is_all_done then
            self:_set_logic_state(Logic_State.diff_online_server_data)
        end
    end

    if Logic_State.diff_online_server_data == self._curr_logic_state then
        local has_diff, allow_join_world_servers = self:_check_online_server_diff()
        if has_diff or self._is_never_lead_rehash then
            self._adjusting_world_online_servers = allow_join_world_servers
            self._adjusting_version = self._version + 1
            self._redis_client:command(1, nil, "del %s", self._redis_key_world_online_servers)
            self:_set_logic_state(Logic_State.persist_online_server_data)
        else
            self:_set_logic_state(Logic_State.guarantee_data_valid)
        end
        self._guarantee_data_valid_over_sec = now_sec + World_Online_Const.guarantee_data_valid_duration_sec
    end

    if Logic_State.persist_online_server_data == self._curr_logic_state then
        -- 当如果redis集群不可达时，要想给个容错策略，
        -- 最简单的就是超时就放弃持久化，且放弃应用新配置
        -- 暂时以now_sec >= self._guarantee_data_valid_over_sec 定为超时
        local is_all_done = self:_persist_online_server_data()
        if is_all_done or now_sec >= self._guarantee_data_valid_over_sec then
            if is_all_done then
                self._lead_world_rehash_state_over_sec = now_sec + World_Online_Const.lead_world_rehash_duration_sec
                self._version = self._adjusting_version
                self._world_online_servers = self._adjusting_world_online_servers
                self._adjusting_version = nil
                self._adjusting_world_online_servers = nil
                self:_set_logic_state(Logic_State.lead_world_rehash)
            else
                self._adjusting_version = nil
                self._adjusting_world_online_servers = nil
                self:_set_logic_state(Logic_State.guarantee_data_valid)
            end
        end
    end

    if Logic_State.lead_world_rehash == self._curr_logic_state then
        if now_sec >= self._lead_world_rehash_state_over_sec then
            self._lead_world_rehash_state_over_sec = nil
            self:_set_logic_state(Logic_State.guarantee_data_valid)
        else
            -- todo:尽其所能全力通知所有关联的server，rehash
            self._is_never_lead_rehash = false
            self:_notify_world_online_data(nil, false)
        end
    end

    if Logic_State.guarantee_data_valid == self._curr_logic_state then
        -- 提前10秒去检查配置是否有变动,如果有变动，
        -- 在Logic_State.persist_online_server_data中等等时间走完，然后设置新值
        if now_sec >= self._guarantee_data_valid_over_sec then
            self:_set_logic_state(Logic_State.diff_online_server_data)
        end
    end
end

function OnlineWorldMonitor:_set_logic_state(state)
    self._curr_logic_state = state
end

function OnlineWorldMonitor:_get_opera_state(opera_name)
    assert(opera_name)
    local ret = Opera_State.free
    if self._opera_states[opera_name] then
        ret = self._opera_states[opera_name]
    end
    -- log_print("OnlineWorldMonitor:_get_opera_state ", opera_name, ret)
    return ret
end

function OnlineWorldMonitor:_set_opera_state(opera_name, opera_state)
    self._opera_states[opera_name] = opera_state
end

function OnlineWorldMonitor:_reset_datas()
    self._curr_logic_state = Logic_State.Free
    self._has_pulled_from_db = false
    self._world_online_servers = {}
    self._version = nil
    self._adjusting_version = nil
    self._opera_states = {}
end

function OnlineWorldMonitor:_check_query_db_logic()
    local opera_state = Opera_State.free
    opera_state = self:_get_opera_state(Opera_Name.query_db_adjusting_version)
    if Opera_State.success ~= opera_state and Opera_State.acting ~= opera_state then
        self:_set_opera_state(Opera_Name.query_db_adjusting_version, Opera_State.acting)
        self._redis_client:command(1, function(ret)
            if Error_None ~= ret:get_error() then
                self:_set_opera_state(Opera_Name.query_db_adjusting_version, Opera_State.fail)
            else
                self:_set_opera_state(Opera_Name.query_db_adjusting_version, Opera_State.success)
                self._adjusting_version = ret:get_reply():get_number()
            end
        end, "get " .. self._redis_key_world_online_adjusting_version)
    end

    opera_state = self:_get_opera_state(Opera_Name.query_db_online_servers)
    if Opera_State.success ~= opera_state and Opera_State.acting ~= opera_state then
        self:_set_opera_state(Opera_Name.query_db_online_servers, Opera_State.acting)
        self._redis_client:command(1, function(ret)
            if Error_None ~= ret:get_error() then
                self:_set_opera_state(Opera_Name.query_db_online_servers, Opera_State.fail)
            else
                local is_ok = false
                if Error_None == ret:get_error() and not ret:get_reply():get_error() then
                    self._world_online_servers = {}
                    local reply_array = ret:get_reply():get_array()
                    if reply_array and #reply_array >= 1 then
                        self._version = reply_array[1]:get_number()
                        if self._version then
                            table.remove(reply_array, 1)
                        end
                        for _, v in pairs(reply_array) do
                            self._world_online_servers[v:get_str()] = true
                        end
                    end
                    is_ok = true
                    self._version = self._version or 1
                end
                self:_set_opera_state(Opera_Name.query_db_online_servers, is_ok and Opera_State.success or Opera_State.fail)
            end
        end, "LRANGE %s 0 -1", self._redis_key_world_online_servers)
    end

    local is_all_done = true
    for _, v in pairs({
        Opera_Name.query_db_adjusting_version,
        Opera_Name.query_db_online_servers,
    }) do
        if Opera_State.success ~= self:_get_opera_state(v) then
            is_all_done = false
        end
    end
    return is_all_done
end

function OnlineWorldMonitor:_check_online_server_diff()
    local has_diff = false
    local allow_join_world_servers = {}
    local allow_join_servers = self._zone_setting:get_allow_join_servers()
    for db_path, is_allow_join in pairs(allow_join_servers) do
        if is_allow_join then
            local server_role, server_name = extract_from_cluster_server_name(db_path)
            if Server_Role.World == server_role and self._zone_setting:is_server_allow_work(string.format("%s.%s", server_role, server_name)) then
                local server_key = string.format(Discovery_Service_Const.db_path_format_zone_server_data,
                        self.server.zone_name, server_role, server_name)
                allow_join_world_servers[server_key] = true
                if not self._world_online_servers[server_key] then
                    has_diff = true
                end
            end
        end
    end
    if not has_diff then
        for server_key, _ in pairs(self._world_online_servers) do
            if not allow_join_world_servers[server_key] then
                has_diff = true
            end
        end
    end
    log_print("OnlineWorldMonitor:_check_online_server_diff", has_diff, allow_join_world_servers, self._world_online_servers)
    return has_diff, allow_join_world_servers
end

function OnlineWorldMonitor:_persist_online_server_data()

    self._redis_client:command(1, function(ret)
        self:_set_opera_state(Opera_Name.set_db_adjusting_version, Opera_State.acting)
        if Error_None ~= ret:get_error() or ret:get_reply():get_error() then
            self:_set_opera_state(Opera_Name.set_db_adjusting_version, Opera_State.fail)
        else
            self:_set_opera_state(Opera_Name.set_db_adjusting_version, Opera_State.success)
        end
    end, "SETEX %s %s %s ", self._redis_key_world_online_adjusting_version, World_Online_Const.lead_world_rehash_duration_sec, self._adjusting_version)

    local opera_state = self:_get_opera_state(Opera_Name.set_db_adjusting_version)
    if Opera_State.success == opera_state then
        opera_state = self:_get_opera_state(Opera_Name.set_db_online_servers)
        if Opera_State.success ~= opera_state and Opera_State.acting ~= opera_state then
            self:_set_opera_state(Opera_Name.set_db_online_servers, Opera_State.acting)
            if not self._adjusting_world_online_servers or not next(self._adjusting_world_online_servers) then
                self:_set_opera_state(Opera_Name.set_db_online_servers, Opera_State.success)
            else
                local cmd = string.format("rpush %s %s %s", self._redis_key_world_online_servers, self._adjusting_version,
                        table.concat(table.keys(self._adjusting_world_online_servers), " "))
                self._redis_client:command(1, function(ret)
                    if Error_None ~= ret:get_error() or ret:get_reply():get_error() then
                        self:_set_opera_state(Opera_Name.set_db_online_servers, Opera_State.fail)
                    else
                        self:_set_opera_state(Opera_Name.set_db_online_servers, Opera_State.success)
                    end
                end, cmd)
            end
        end
    end

    local is_all_done = true
    for _, v in pairs({
        Opera_Name.set_db_adjusting_version,
        Opera_Name.set_db_online_servers,
    }) do
        if Opera_State.success ~= self:_get_opera_state(v) then
            is_all_done = false
        end
    end
    return is_all_done
end

function OnlineWorldMonitor:_notify_world_online_data(to_server_key, is_simple_info)
    local notify_servers = nil
    if to_server_key then
        notify_servers = { to_server_key }
    else
        notify_servers = self.server.peer_net:get_role_server_keys(Server_Role.World)
    end
    local send_tb = {
        version = self._version,
    }
    if self._lead_world_rehash_state_over_sec then
        send_tb.lead_rehash_left_sec = self._lead_world_rehash_state_over_sec - logic_sec()
    end
    if not is_simple_info then
        send_tb.servers = self._world_online_servers
    end
    -- log_print("OnlineWorldMonitor:_notify_world_online_data", notify_servers, send_tb)
    for _, v in pairs(notify_servers) do
        self.server.rpc:call(nil, v, World_Online_Rpc_Method.notify_world_online_servers_data, send_tb)
    end
end

---@param rsp RpcRsp
function OnlineWorldMonitor:_on_rpc_query_world_online_servers_data(rsp, is_simple_info)
    rsp:response()
    self:_notify_world_online_data(rsp.from_host, is_simple_info)
end
