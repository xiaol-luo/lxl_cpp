
---@class CreateRoleAgentLogic:LogicEntity
CreateRoleAgentLogic = CreateRoleAgentLogic or class("CreateRoleAgentLogic", LogicEntity)

function CreateRoleAgentLogic:ctor(logic_svc, logic_name)
    CreateRoleAgentLogic.super.ctor(self, logic_svc, logic_name)
end

function CreateRoleAgentLogic:_on_init()
    CreateRoleAgentLogic.super._on_init(self)
end

function CreateRoleAgentLogic:_on_start()
    CreateRoleAgentLogic.super._on_start(self)
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.query_roles, Functional.make_closure(self._handle_remote_call_query_roles, self))
    -- self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.create_role.method.create_role, Functional.make_closure(self._handle_remote_call_create_role, self))
end

function CreateRoleAgentLogic:_on_stop()
    CreateRoleAgentLogic.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function CreateRoleAgentLogic:_on_release()
    CreateRoleAgentLogic.super._on_release(self)
end

function CreateRoleAgentLogic:_on_update()
    -- log_print("CreateRoleAgentLogic:_on_update")
end


