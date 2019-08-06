

function LoginService:setup_logics()
    self.logic_mgr:add_logic(LoginGameMgr:new(self.logic_mgr, "login_game_mgr"))
end