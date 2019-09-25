

function RobotService:setup_logics()
    self.logic_mgr:add_logic(LoginAction:new(self.logic_mgr, "LoginAction"))
    for i=1, 1 do
        self.logic_mgr:add_logic(LoginAction:new(self.logic_mgr, string.format("LoginAction_%d", i)))
    end
    -- self.logic_mgr:add_logic(TestRedisClient:new(self.logic_mgr, "TestRedisClient"))
end