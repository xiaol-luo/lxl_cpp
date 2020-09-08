
---@class GameRoleMgrHandleClientFns
GameRoleMgrHandleClientMsgFns = GameRoleMgrHandleClientFns or {}

---@param self GameRoleMgr
function GameRoleMgrHandleClientMsgFns.pull_role_data(self, from_gate, gate_netid, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        return
    end
    role:send_msg(Main_Role_Pid.sync_role_data, {
        role_id = role:get_role_id(),
        pull_type = msg.pull_type,
        base_info = {
            role_name = role.base_info:get_role_name(),
        }
    })
end



