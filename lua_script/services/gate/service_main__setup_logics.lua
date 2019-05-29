

function GateService:setup_logics()
    self.logic_mgr:add_logic(ClientMgr:new(self.logic_mgr, "client_mgr"))
end