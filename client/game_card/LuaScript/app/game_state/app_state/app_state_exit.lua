
AppStateExit = AppStateExit or class("AppStateExit", AppStateBase)

function AppStateExit:ctor(state_mgr, app)
    AppStateExit.super.ctor(self, state_mgr, App_State_Name.exit, app)
end
