
AppStateExitGame = AppStateExitGame or class("AppStateExitGame", AppStateBase)

function AppStateExitGame:ctor(state_mgr, app)
    AppStateExitGame.super.ctor(self, state_mgr, App_State_Name.exit_game, app)
end
