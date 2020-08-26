
---@class WorldAgentLogic:GameLogicEntity
---@field server GateServer
WorldAgentLogic = WorldAgentLogic or class("WorldAgentLogic", GameLogicEntity)

function WorldAgentLogic:ctor(logics, logic_name)
    WorldAgentLogic.super.ctor(self, logics, logic_name)
    ---@type GateClientMgr
    self._gate_client_mgr = nil
    ---@type OnlineWorldShadow
    self._work_world_shadow = nil
end

function WorldAgentLogic:_on_init()
    WorldAgentLogic.super._on_init(self)
    self._gate_client_mgr = self.logics.gate_client_mgr
    self._work_world_shadow = self.server.work_world_shadow
end

function WorldAgentLogic:_on_start()
    WorldAgentLogic.super._on_start(self)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_launch_role, Functional.make_closure(self._on_msg_launch_role, self))
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_logout_role, Functional.make_closure(self._on_msg_logout_role, self))
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_reconnect_role, Functional.make_closure(self._on_msg_reconnect_role, self))
end

function WorldAgentLogic:_on_stop()
    WorldAgentLogic.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_pull_role_digest, nil)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_logout_role, nil)
    self._gate_client_mgr:set_msg_handler(Login_Pid.req_reconnect_role, nil)
end

function WorldAgentLogic:_on_release()
    WorldAgentLogic.super._on_release(self)
end

function WorldAgentLogic:_on_update()
    -- log_print("WorldAgentLogic:_on_update")
end

---@param gate_client GateClient
function WorldAgentLogic:_on_msg_launch_role(gate_client, pid, msg)
    local error_num = Error_None
    repeat
        local find_error_num, selected_world_key = self._work_world_shadow:find_available_server_address(msg.role_id)
        if Error_None ~= find_error_num then
            error_num = find_error_num
            break
        end
        if Gate_Client_State.manage_role ~= gate_client.state then
            error_num = Error.launch_role.gate_client_state_not_fit
            break
        end
        if not gate_client.user_id then
            error_num = Error_Unknown
            break
        end
        gate_client.state = Gate_Client_State.launch_role
        self._rpc_svc_proxy:call(
                Functional.make_closure(self._rpc_rsp_req_launch_role, self, gate_client.netid, msg.role_id),
                selected_world_key, Rpc.world.method.launch_role, gate_client.netid, gate_client.auth_sn, gate_client.user_id, msg.role_id
        )
    until true

    if Error_None ~= error_num then
        gate_client:send_msg(Login_Pid.rsp_launch_role, { error_num = error_num, role_id = msg.role_id })
    end
end

function WorldAgentLogic:_rpc_rsp_req_launch_role(gate_netid, role_id, rpc_error_num, launch_error_num, game_server_key, session_id)
    local gate_client = self._gate_client_mgr:get_client(gate_netid)
    if not gate_client then
        return
    end

    local error_num = Error_None
    repeat
        local picked_error_num = pick_error_num(rpc_error_num, launch_error_num)
        if Error_None ~= picked_error_num then
            error_num = picked_error_num
            break
        end
        if not gate_client or Gate_Client_State.launch_role ~= gate_client.state then
            error_num = Error.launch_role.gate_client_state_not_fit
            break
        end
        gate_client.state = Gate_Client_State.in_game
        gate_client.role_id = role_id
        gate_client.game_server_key = game_server_key
        gate_client.session_id = session_id
    until true
    if Error_None ~= error_num then
        if not gate_client and Gate_Client_State.launch_role == gate_client.state then
            gate_client.state = Gate_Client_State.manage_role
        end
    end
    gate_client:send_msg(Login_Pid.rsp_launch_role, { error_num = error_num, role_id = role_id })
end

function WorldAgentLogic:_on_msg_logout_role(gate_client, pid, msg)
    local error_num = Error_None
    repeat
        if Gate_Client_State.in_game ~= gate_client.state or not gate_client.role_id or gate_client.role_id ~= msg.role_id  then
            error_num = Error.logout_role.gate_client_state_not_fit
            break
        end
        local find_error_num, selected_world_key = self._work_world_shadow:find_available_server_address(gate_client.role_id)
        if Error_None ~= find_error_num then
            error_num = find_error_num
            break
        end
        self._rpc_svc_proxy:call(
                Functional.make_closure(self._rpc_rsp_logout_role, self, gate_client.netid, gate_client.session_id),
                selected_world_key, Rpc.world.method.logout_role, gate_client.session_id)
    until true

    if Error_None ~= error_num then
        gate_client:send_msg(Login_Pid.rsp_logout_role, { error_num = error_num  })
    end
end

function WorldAgentLogic:_rpc_rsp_logout_role(gate_netid, session_id, rpc_error_num, logic_error_num)
    local gate_client = self._gate_client_mgr:get_client(gate_netid)
    if not gate_client or gate_client.session_id ~= session_id then
        return
    end
    if Gate_Client_State.in_game ~= gate_client.state then
        return
    end

    local error_num = Error_None
    repeat
        local picked_error_num = pick_error_num(rpc_error_num, logic_error_num)
        if Error_None ~= picked_error_num then
            error_num = picked_error_num
            break
        end
        gate_client.state = Gate_Client_State.manage_role
        gate_client.role_id = nil
        gate_client.session_id = nil
        gate_client.game_server_key = nil
    until true
    gate_client:send_msg(Login_Pid.rsp_logout_role, { error_num = error_num })
end

function WorldAgentLogic:_on_msg_reconnect_role(gate_client, pid, msg)
    -- todo: 补认证过程
    local error_num = Error_None
    local auth_msg = msg.login_gate_data
    repeat
        if Gate_Client_State.free ~= gate_client.state then
            error_num = Error.reconnect_role.gate_client_state_not_fit
            break
        end

        ---@type GateLogic
        local gate_logic = self.server.logics.gate
        gate_logic:try_login_gate(gate_client, msg.login_gate_data, function(login_gate_error_num)
            if Error_None ~= login_gate_error_num then
                gate_client:send_msg(Login_Pid.rsp_reconnect_role, { error_num = login_gate_error_num, role_id = msg.role_id })
                return
            end

            local error_num = Error_None
            local find_error_num, selected_world_key = self._work_world_shadow:find_available_server_address(msg.role_id)
            if Error_None ~= find_error_num then
                error_num = find_error_num
            else
                gate_client.state = Gate_Client_State.launch_role
                self._rpc_svc_proxy:call(
                        Functional.make_closure(self._rpc_rsp_reconnect_role, self, gate_client.netid, msg.role_id),
                        selected_world_key, Rpc.world.method.reconnect_role, gate_client.netid, msg.role_id, gate_client.auth_sn
                )
            end
            if Error_None ~= error_num then
                gate_client:send_msg(Login_Pid.rsp_reconnect_role, { error_num = error_num, role_id = msg.role_id })
            end
        end)
    until true

    if Error_None ~= error_num then
        gate_client:send_msg(Login_Pid.rsp_reconnect_role, { error_num = error_num, role_id = msg.role_id })
    end
end

function WorldAgentLogic:_rpc_rsp_reconnect_role(netid, role_id, rpc_error_num, logic_error_num, game_server_key, session_id)
    local gate_client = self._gate_client_mgr:get_client(netid)
    if not gate_client then
        return
    end

    local error_num = Error_None
    local picked_error_num = pick_error_num(rpc_error_num, logic_error_num)
    if Error_None ~= picked_error_num then
        error_num = picked_error_num
        if Gate_Client_State.launch_role == gate_client.state then
            gate_client.state = Gate_Client_State.manage_role
            gate_client.auth_sn = nil
        end
    else
        if Gate_Client_State.launch_role == gate_client.state then
            gate_client.state = Gate_Client_State.in_game
            gate_client.game_server_key = game_server_key
            gate_client.session_id = session_id
            gate_client.role_id = role_id
        else
            error_num = Error.reconnect_role.gate_client_state_not_fit
        end
    end
    gate_client:send_msg(Login_Pid.rsp_reconnect_role, { error_num = error_num, role_id = role_id })
end

