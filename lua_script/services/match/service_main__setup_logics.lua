

function LoginService:setup_logics()
    self.logic_mgr:add_logic(MatchMgr:new(self.logic_mgr, "match_mgr"))
    self.logic_mgr:add_logic(RoomMgr:new(self.logic_mgr, "room_mgr"))
end