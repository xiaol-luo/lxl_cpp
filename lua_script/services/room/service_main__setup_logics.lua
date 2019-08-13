

function RoomService:setup_logics()
    self.logic_mgr:add_logic(FightAgentMgr:new(self.logic_mgr, "fight_agent_mgr"))
    self.logic_mgr:add_logic(RoomMgr:new(self.logic_mgr, "room_mgr"))
end