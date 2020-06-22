
local Logic_State = {
    free = "free",
    reset_all = "reset_all",
    wait_join_cluster = "wait_join_cluster",
    joined_cluster = "joined_cluster",
    wait_pull_persistent_data = "wait_pull_persistent_data",
    pulled_persistent_data = "pulled_persistent_data",
    diff_online_server_data = "diff_online_server_data",
    persist_online_server_data = "persist_online_server_data",
    sync_online_server_data = "sync_online_server_data",
    wait_online_server_change = "wait_online_server_change",
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
    ---@type RedisClient
    self._redis_key_online_world_adjusting_version = string.format(Online_World_Const.redis_key_online_world_adjusting_version_format, self.server.zone)
    self._redis_key_online_world_version = string.format(Online_World_Const.redis_key_online_world_version_format, self.server.zone)
    self._redis_key_online_world_servers = string.format(Online_World_Const.redis_key_online_world_servers_format, self.server.zone)

    self._redis_client = nil
    self._zone_setting = self.server.zone_setting

    self._curr_logic_state = Logic_State.Free
    self._has_pulled_from_db = false
    self._online_world_servers = {}
    self._version = nil
    self._adjusting_version = nil
    self._opera_states = {}
end

function OnlineWorldMonitor:_on_init()
    OnlineWorldMonitor.super:_on_init(self)
    ---@type RedisServerConfig
    local redis_cfg = self.server.redis_online_servers_setting
    self._redis_client = RedisClient:new(redis_cfg.is_cluster, redis_cfg.host, redis_cfg.pwd, redis_cfg.thread_num, redis_cfg.cnn_timeout_ms, redis_cfg.cmd_timeout_ms)
    self._curr_logic_state = Logic_State.free
end

function OnlineWorldMonitor:_on_start()
    OnlineWorldMonitor.super._on_start(self)
    local ret = self._redis_client:start()
    if not ret then
        self._error_num = -1
        self._error_msg = "OnlineWorldMonitor start redis client fail"
        return
    end

    self._curr_logic_state = self:_set_logic_state(Logic_State.Reset_All)

    -- self:_try_pull_data()
end

function OnlineWorldMonitor:_on_stop()
    OnlineWorldMonitor.super._on_stop(self)
    self._redis_client:stop()
end

function OnlineWorldMonitor:_on_release()
    OnlineWorldMonitor.super._on_release(self)
    self._curr_logic_state = Logic_State.Released
end

function OnlineWorldMonitor:_on_update()
    -- log_print("OnlineWorldMonitor:_on_update")
    OnlineWorldMonitor.super._on_update(self)

    if false then
        if not self._last_sec or logic_sec() - self._last_sec > 5 then
            self._last_sec = logic_sec()

            local cmd = ""

            cmd = string.format("set %s %d", self._redis_key_online_world_adjusting_version, 10)
            self._redis_client:command(2, function(ret)
                log_print("OnlineWorldMonitor:_on_update ", self._redis_key_online_world_adjusting_version, ret)
            end, cmd)

            cmd = string.format("set %s %d", self._redis_key_online_world_version, 1)
            self._redis_client:command(2, function(ret)
                log_print("OnlineWorldMonitor:_on_update ", self._redis_key_online_world_version, ret)
            end, cmd)

--[[            self._redis_client:command(1, nil, "del %s", self._redis_key_online_world_servers)
            cmd = string.format("rpush %s '%s' %s", self._redis_key_online_world_servers, "hello", "world")
            self._redis_client:command(2, function(ret)
                log_print("OnlineWorldMonitor:_on_update ", self._redis_key_online_world_servers, ret)
            end, cmd)]]

        end
    end
    self:_tick_logic()
end

function OnlineWorldMonitor:_tick_logic()
    if Logic_State.reset_all == self._curr_logic_state then
        self._curr_logic_state = Logic_State.Free
        self._has_pulled_from_db = false
        self._online_world_servers = {}
        self._version = nil
        self._adjusting_version = nil
        self._opera_states = {}
        self:_set_logic_state(Logic_State.Wait_Join_Cluster)
    end

    if Logic_State.wait_join_cluster == self._curr_logic_state then
        if self.server.discovery:is_joined_cluster() then
            self:_set_logic_state(Logic_State.Joined_Cluster)
        end
    end
    if Logic_State.joined_cluster == self._curr_logic_state then

    end
end

function OnlineWorldMonitor:_try_pull_data()
    self._redis_client:command(1, function(ret)
        log_print("OnlineWorldMonitor:_try_pull_data", self._redis_key_online_world_adjusting_version, ret)
        self:_try_pull_data()
        self._adjusting_version = ret:get_number()
    end, string.format("get %s", self._redis_key_online_world_adjusting_version))

    self._redis_client:command(1, function(ret)
        log_print("OnlineWorldMonitor:_try_pull_data", self._redis_key_online_world_version, ret)
        -- self:_try_pull_data()
        self._has_pulled_from_db = true

        self._version = ret:get_number()
    end, string.format("get %s", self._redis_key_online_world_version))

    self._redis_client:command(1, function(ret)
        self._has_pulled_from_db = true

        -- log_print("OnlineWorldMonitor:_try_pull_data", self._redis_key_online_world_servers, ret)
    end, string.format("LRANGE %s 0 -1", self._redis_key_online_world_servers))
end

function OnlineWorldMonitor:_set_logic_state(state)
    self._curr_logic_state = state
end

function OnlineWorldMonitor:_get_opera_state(opera_name)
    local ret = Opera_State.free
    if self._opera_states[opera_name] then
        ret = self._opera_states[opera_name]
    end
    return ret
end

function OnlineWorldMonitor:_set_opera_state(opera_name, opera_state)
    self._opera_states[opera_name] = opera_state
end
