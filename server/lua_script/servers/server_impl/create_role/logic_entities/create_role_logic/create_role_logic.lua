
---@class CreateRoleLogic:LogicEntity
CreateRoleLogic = CreateRoleLogic or class("CreateRoleLogic", LogicEntity)

function CreateRoleLogic:_on_init()
    CreateRoleLogic.super._on_init(self)
end

function CreateRoleLogic:_on_start()
    CreateRoleLogic.super._on_start(self)
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.query_roles, Functional.make_closure(self._handle_remote_call_query_roles, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.create_role, Functional.make_closure(self._handle_remote_call_create_role, self))
end

function CreateRoleLogic:_on_stop()
    CreateRoleLogic.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function CreateRoleLogic:_on_release()
    CreateRoleLogic.super._on_release(self)
end

function CreateRoleLogic:_on_update()
    -- log_print("CreateRoleLogic:_on_update")
end

---@param rsp RpcRsp
function CreateRoleLogic:_handle_remote_call_query_roles(rsp)
    rsp:respone()
    log_print("CreateRoleLogic:_handle_remote_call_query_roles")
end

---@param rsp RpcRsp
function CreateRoleLogic:_handle_remote_call_create_role(rsp)
    log_print("CreateRoleLogic:_handle_remote_call_create_role")
    rsp:respone()
end

