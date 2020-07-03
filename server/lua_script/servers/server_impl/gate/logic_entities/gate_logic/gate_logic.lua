
---@class GateLogic:LogicEntity
GateLogic = GateLogic or class("GateLogic", LogicEntity)

function GateLogic:_on_init()
    GateLogic.super._on_init(self)
end

function GateLogic:_on_start()
    GateLogic.super._on_start(self)
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.query_roles, Functional.make_closure(self._handle_remote_call_query_roles, self))
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.create_role, Functional.make_closure(self._handle_remote_call_create_role, self))
end

function GateLogic:_on_stop()
    GateLogic.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function GateLogic:_on_release()
    GateLogic.super._on_release(self)
end

function GateLogic:_on_update()
    -- log_print("GateLogic:_on_update")
    local server_key = self.server.peer_net:random_server_key(Server_Role.Create_Role)
    if server_key then
        -- log_print("GateLogic:_on_update 1")
        --self._rpc_svc_proxy:call(function(...)
        --    log_print("Rpc.create_role.method.query_roles", ...)
        --end, server_key, Rpc.create_role.method.query_roles)
    end
end


