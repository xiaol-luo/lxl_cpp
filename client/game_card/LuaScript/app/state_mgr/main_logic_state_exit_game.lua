
MainLogicStateExitGame = MainLogicStateExitGame or class("MainLogicStateExitGame", MainLogicStateBase)

function MainLogicStateExitGame:ctor(state_mgr, main_logic)
    MainLogicStateExitGame.super.ctor(self, state_mgr, Main_Logic_State_Name.exit_game, main_logic)
end
