

function ExampleService:setup_logics()
    self.logic_mgr:add_logic(FightMgr:new(self.logic_mgr, "fight_mgr"))
end