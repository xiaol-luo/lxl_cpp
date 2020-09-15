
RoleFightHandleClientMsgFns = RoleFightHandleClientMsgFns or {}

---@param self GameRoleMgr
function RoleFightHandleClientMsgFns.req_join_match(self, from_gate, gate_netid, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        ---@type GameServer
        local server_ins = SERVER_INS
        server_ins.logics.forward_msg:send_msg_to_client(from_gate, gate_netid, Fight_Pid.rsp_join_match, { error_num = Error_Not_Find_Role })
        return
    end
    role.fight:on_msg_req_join_match(pid, msg)
end

---@param self GameRoleMgr
function RoleFightHandleClientMsgFns.req_quit_match(self, from_gate, gate_netid, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        return server_ins.logics.forward_msg:send_msg_to_client(from_gate, gate_netid, Fight_Pid.req_quit_match, { error_num = Error_Not_Find_Role })
    end
    role.fight:on_msg_req_quit_match(pid, msg)
end

---@param self GameRoleMgr
function RoleFightHandleClientMsgFns:query_fight_state(self, from_gate, gate_netid, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        return server_ins.logics.forward_msg:send_msg_to_client(from_gate, gate_netid, Fight_Pid.req_quit_match, { error_num = Error_Not_Find_Role })
    end
    role.fight:sync_fight_state(pid, msg)
end