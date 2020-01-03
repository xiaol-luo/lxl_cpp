
InGameStateLogout = InGameStateLogout or class("InGameStateLogout", InGameStateBase)

function InGameStateLogout:ctor(state_mgr, in_game_state)
    InGameStateLogout.super.ctor(self, state_mgr, In_Game_State_Name.logout)
    self.in_game_state = in_game_state
end
