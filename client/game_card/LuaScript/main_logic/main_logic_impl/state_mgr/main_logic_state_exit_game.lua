
MainLogicStateExitGame = MainLogicStateExitGame or class("MainLogicStateExitGame", MainLogicStateBase)

function MainLogicStateExitGame:ctor(state_mgr)
    MainLogicStateExitGame.super.ctor(self, state_mgr, Main_Logic_State_Name.exit_game)
end
