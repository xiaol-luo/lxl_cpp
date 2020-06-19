---@class OnlineWorldShadow: ServiceBase
OnlineWorldShadow = OnlineWorldShadow or class("OnlineWorldShadow", ServiceBase)

function OnlineWorldShadow:ctor(service_mgr, service_name)
    OnlineWorldShadow.super.ctor(self, service_mgr, service_name)
    ---@type RedisClient
    self._redis_client = nil
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
        self._error_msg = "OnlineWorldMonitor start redis client fail"
        return
    end
end

function OnlineWorldShadow:_on_stop()
    OnlineWorldShadow.super._on_stop(self)
    self._redis_client:stop()
end

function OnlineWorldShadow:_on_release()
    OnlineWorldShadow.super._on_release(self)
end

function OnlineWorldShadow:_on_update()
    OnlineWorldShadow.super._on_update(self)
end
