
AppStateExitGame = AppStateExitGame or class("AppStateExitGame", AppStateBase)

function AppStateExitGame:ctor(state_mgr, main_logic)
    AppStateExitGame.super.ctor(self, state_mgr, App_State_Name.exit_game, main_logic)
end
