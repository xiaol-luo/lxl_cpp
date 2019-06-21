

function GameService:setup_logics()
    self.logic_mgr:add_logic(ManageRoleLogic:new(self.logic_mgr, "role_mgr"))
end
