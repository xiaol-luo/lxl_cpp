

function MatchService:setup_logics()
    self.logic_mgr:add_logic(MatchMgr:new(self.logic_mgr, "match_mgr"))
    self.logic_mgr:add_logic(RoomMgr:new(self.logic_mgr, "room_mgr"))
    self.logic_mgr:add_logic(MessLogic:new(self.logic_mgr, "_mess_logic"))
    self.logic_mgr:add_logic(RoleMgr:new(self.logic_mgr, "role_mgr"))
end