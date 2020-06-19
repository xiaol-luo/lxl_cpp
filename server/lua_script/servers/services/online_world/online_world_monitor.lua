
---@class OnlineWorldMonitor: ServiceBase
OnlineWorldMonitor = OnlineWorldMonitor or class("OnlineWorldMonitor", ServiceBase)

function OnlineWorldMonitor:ctor(service_mgr, service_name)
    OnlineWorldMonitor.super.ctor(self, service_mgr, service_name)
    ---@type RedisClient
    self._redis_client = nil
    self._zone_setting = self.server.zone_setting
    self._has_pulled_from_db = false
    self._online_world_servers = {}
    self._version = nil
    self._adjusting_version = nil

    self._redis_key_online_world_adjusting_version = string.format(Online_World_Const.redis_key_online_world_adjusting_version_format, self.server.zone)
    self._redis_key_online_world_version = string.format(Online_World_Const.redis_key_online_world_version_format, self.server.zone)
    self._redis_key_online_world_servers = string.format(Online_World_Const.redis_key_online_world_servers_format, self.server.zone)
end

function OnlineWorldMonitor:_on_init()
    OnlineWorldMonitor.super:_on_init(self)
    ---@type RedisServerConfig
    local redis_cfg = self.server.redis_online_servers_setting
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
    self:_try_pull_data()
end

function OnlineWorldMonitor:_on_stop()
    OnlineWorldMonitor.super._on_stop(self)
    self._redis_client:stop()
end

function OnlineWorldMonitor:_on_release()
    OnlineWorldMonitor.super._on_release(self)
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



