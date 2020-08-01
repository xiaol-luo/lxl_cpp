
---@class AppStateInit:AppStateBase
AppStateInit = AppStateInit or class("AppStateInit", AppStateBase)

function AppStateInit:ctor(state_mgr, app)
    AppStateInit.super.ctor(self, state_mgr, App_State_Name.init, app)
end

function AppStateInit:on_enter(params)
    AppStateInit.super.on_enter(self, params)
    self.app.panel_mgr:prepare_assets()
end

function AppStateInit:on_update()
    AppStateInit.super.on_update(self)
    if self:is_all_done() then
        self.state_mgr:change_state(App_State_Name.login)
    end
end

function AppStateInit:on_exit()
    AppStateInit.super.on_exit(self)
end

function AppStateInit:is_all_done()
    return true
end