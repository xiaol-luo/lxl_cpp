
InGameStateExit = InGameStateExit or class("InGameStateExit", InGameStateBase)

function InGameStateExit:ctor(state_mgr, in_game_state)
    InGameStateExit.super.ctor(self, state_mgr, In_Game_State_Name.exit)
    self.in_game_state = in_game_state
end


