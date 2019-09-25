

function GameService:setup_logics()
    self.logic_mgr:add_logic(RoleMgr:new(self.logic_mgr, "role_mgr"))
    self.logic_mgr:add_logic(NetForward:new(self.logic_mgr, "net_forward"))
    self.logic_mgr:add_logic(MatchAgentMgr:new(self.logic_mgr, "match_agent_mgr"))
end
