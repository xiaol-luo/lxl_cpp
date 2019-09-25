

function WorldService:setup_logics()
    self.logic_mgr:add_logic(RoleMgr:new(self.logic_mgr, "manage_role"))
end