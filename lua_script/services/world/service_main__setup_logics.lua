

function WorldService:setup_logics()
    self.logic_mgr:add_logic(ManageRoleLogic:new(self.logic_mgr, "manage_role"))
end