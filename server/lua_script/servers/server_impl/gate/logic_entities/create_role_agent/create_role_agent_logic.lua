
---@class CreateRoleAgentLogic:LogicEntity
CreateRoleAgentLogic = CreateRoleAgentLogic or class("CreateRoleAgentLogic", LogicEntity)

function CreateRoleAgentLogic:ctor(logics, logic_name)
    CreateRoleAgentLogic.super.ctor(self, logics, logic_name)
    ---@type GateClientMgr
    self._gate_client_mgr = nil
end

function CreateRoleAgentLogic:_on_init()
    CreateRoleAgentLogic.super._on_init(self)
    self._gate_client_mgr = self.logics.gate_client_mgr
end

function CreateRoleAgentLogic:_on_start()
    CreateRoleAgentLogic.super._on_start(self)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_pull_role_digest, Functional.make_closure(self._on_msg_query_roles, self))
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_create_role, Functional.make_closure(self._on_msg_create_role, self))
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

function CreateRoleAgentLogic:_on_msg_query_roles(gate_client, pid, msg)
    local server_key = self.server.peer_net:random_server_key(Server_Role.Create_Role)
    if server_key then
        self._rpc_svc_proxy:call(function(rpc_error_num, error_num, role_digests)
            local msg = {}
            if Error_None == rpc_error_num then
                msg.error_num = error_num
                msg.role_id = msg.role_id
                if Error_None == error_num then
                    msg.role_digests = role_digests
                end
            else
                msg.error_num = rpc_error_num
            end
            if Error_None ~= msg.error_num then
                -- log_print("Rpc.create_role.method.query_roles", msg)
            end

            gate_client:send_msg(Login_Pid.rsp_pull_role_digest, msg)
        end, server_key, Rpc.create_role.method.query_roles, gate_client.user_id, msg.role_id)
    end
end

function CreateRoleAgentLogic:_on_msg_create_role(gate_client, pid, msg)
    local server_key = self.server.peer_net:random_server_key(Server_Role.Create_Role)
    if server_key then
        self._rpc_svc_proxy:call(function(rpc_error_num, error_num, role_id)
            local msg = {}
            if Error_None == rpc_error_num then
                msg.error_num = error_num
                if Error_None == error_num then
                    msg.role_id = role_id
                end
            else
                msg.error_num = rpc_error_num
            end
            -- log_print("Rpc.create_role.method._create_role", msg)
            gate_client:send_msg(Login_Pid.rsp_create_role, msg)
        end, server_key, Rpc.create_role.method.create_role, gate_client.user_id, msg.params)
    end
end


