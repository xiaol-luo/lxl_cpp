
RoleFightHandleClientMsgFns = RoleFightHandleClientMsgFns or {}

---@param self GameRoleMgr
function RoleFightHandleClientMsgFns.req_join_match(self, from_gate, gate_netid, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        return
    end
    role.fight:req_join_match(pid, msg)
end

---@param self GameRoleMgr
function RoleFightHandleClientMsgFns.req_quit_match(self, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        return
    end
    role.fight:req_quit_match(pid, msg)
end