

function RobotService:setup_logics()
    self.logic_mgr:add_logic(LoginAction:new(self.logic_mgr, "LoginAction"))
end