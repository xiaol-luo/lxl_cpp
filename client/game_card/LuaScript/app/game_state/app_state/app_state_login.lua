
---@class AppStateLogin:AppStateBase
AppStateLogin = AppStateLogin or class("AppStateLogin", AppStateBase)

function AppStateLogin:ctor(state_mgr, app)
    AppStateLogin.super.ctor(self, state_mgr, App_State_Name.login, app)
end

function AppStateLogin:on_enter(params)
    AppStateLogin.super.on_enter(self, params)
    self._is_all_done = false
    if not self:is_all_done()  then
        self.app.panel_mgr:open_panel(UI_Panel_Name.login_panel, {})
    end
end

function AppStateLogin:on_update()
    AppStateLogin.super.on_update(self)

    if self:is_all_done() then
        self.state_mgr:change_state(App_State_Name.in_game)
    end
end

function AppStateLogin:on_exit()
    AppStateLogin.super.on_exit(self)
    self.app.panel_mgr:release_panel(UI_Panel_Name.login_panel)
end

function AppStateLogin:is_all_done()
    local ret = self.app.net_mgr.game_platform_net:is_ready() and self.app.net_mgr.game_login_net:is_ready()
    return ret
end