
InGameStateRun = InGameStateRun or class("InGameStateRun", InGameStateBase)

function InGameStateRun:ctor(state_mgr, in_game_state)
    InGameStateRun.super.ctor(self, state_mgr, In_Game_State_Name.run, in_game_state)
end
