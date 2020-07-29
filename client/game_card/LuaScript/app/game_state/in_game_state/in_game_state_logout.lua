
InGameStateLogout = InGameStateLogout or class("InGameStateLogout", InGameStateBase)

function InGameStateLogout:ctor(state_mgr, in_game_state)
    InGameStateLogout.super.ctor(self, state_mgr, In_Game_State_Name.logout, in_game_state)
end

function InGameStateLogout:on_enter(params)
    InGameStateEnter.super.on_enter(params)
    -- todo
    -- self.main_logic.main_role:update_data(nil)
    self.state_mgr:change_state(In_Game_State_Name.login)
end

