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
    if self.server.discovery:is_joined_cluster() then
        local server_key = self.server.peer_net:rand_role_server_key(Server_Role.World_Sentinel)
        if server_key then
            self.server.rpc:call(nil, server_key, Online_World_Rpc_Method.query_online_world_servers_data, 1, 2)
        end
    end
end

---@param rsp RpcRsp
function OnlineWorldShadow:_on_rpc_notify_online_world_servers_data(rsp, ...)
    -- log_print("-------------------------- OnlineWorldShadow:_on_rpc_notify_online_world_servers_data", ...)
    rsp:respone()
end
