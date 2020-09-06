
---@class GameRoleMgrHandleClientFns
GameRoleMgrHandleClientMsgFns = GameRoleMgrHandleClientFns or {}

---@param self GameRoleMgr
function GameRoleMgrHandleClientMsgFns.pull_role_data(self, role_id, pid, msg)
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

---@param self GameRoleMgr
function GameRoleMgrHandleClientMsgFns.req_join_match(self, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        return
    end
    role.fight:req_join_match(pid, msg)
end

---@param self GameRoleMgr
function GameRoleMgrHandleClientMsgFns.req_quit_match(self, role_id, pid, msg)
    local role = self:get_role(role_id)
    if not role then
        return
    end
    role.fight:req_quit_match(pid, msg)
end

