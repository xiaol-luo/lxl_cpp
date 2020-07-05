
---@class CreateRoleAgentLogic:LogicEntity
CreateRoleAgentLogic = CreateRoleAgentLogic or class("CreateRoleAgentLogic", LogicEntity)

function CreateRoleAgentLogic:ctor(logic_svc, logic_name)
    CreateRoleAgentLogic.super.ctor(self, logic_svc, logic_name)
    ---@type GateClientMgr
    self._gate_client_mgr = nil
end

function CreateRoleAgentLogic:_on_init()
    CreateRoleAgentLogic.super._on_init(self)
    self._gate_client_mgr = self.logic_svc.gate_client_mgr
end

function CreateRoleAgentLogic:_on_start()
    CreateRoleAgentLogic.super._on_start(self)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_pull_role_digest, Functional.make_closure(self._query_roles, self))
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_create_role, Functional.make_closure(self._create_role, self))
end

function CreateRoleAgentLogic:_on_stop()
    CreateRoleAgentLogic.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_pull_role_digest, nil)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_create_role, nil)
end

function CreateRoleAgentLogic:_on_release()
    CreateRoleAgentLogic.super._on_release(self)
end

function CreateRoleAgentLogic:_on_update()
    -- log_print("CreateRoleAgentLogic:_on_update")
end

function CreateRoleAgentLogic:_query_roles(gate_client, pid, msg)
    local server_key = self.server.peer_net:random_server_key(Server_Role.Create_Role)
    if server_key then
        self._rpc_svc_proxy:call(function(rpc_error_num, ...)
            log_print("Rpc.create_role.method.query_roles", rpc_error_num, ...)
            gate_client:send_msg(Login_Pid.rsp_pull_role_digest, {
                error_num = rpc_error_num,
                role_digests = {},
            })
        end, server_key, Rpc.create_role.method.query_roles, gate_client.user_id, msg.role_id)
    end
end

function CreateRoleAgentLogic:_create_role(gate_client, pid, msg)
    local server_key = self.server.peer_net:random_server_key(Server_Role.Create_Role)
    if server_key then
        self._rpc_svc_proxy:call(function(rpc_error_num, ...)
            log_print("Rpc.create_role.method._create_role", rpc_error_num, ...)
            gate_client:send_msg(Login_Pid.rsp_create_role, {
                error_num = rpc_error_num,
                role_id = 0,
            })
        end, server_key, Rpc.create_role.method.create_role, gate_client.user_id, msg.params)
    end
end


