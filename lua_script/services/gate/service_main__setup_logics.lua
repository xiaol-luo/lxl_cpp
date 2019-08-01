

function GateService:setup_logics()
    self.logic_mgr:add_logic(ClientMgr:new(self.logic_mgr, "client_mgr"))
    self.logic_mgr:add_logic(NetForward:new(self.logic_mgr, "net_forward"))
end