

function RobotService:setup_logics()
    self.logic_mgr:add_logic(LoginAction:new(self.logic_mgr, "LoginAction"))
    for i=1, 0 do
        self.logic_mgr:add_logic(LoginAction:new(self.logic_mgr, string.format("LoginAction_%d", i)))
    end
end