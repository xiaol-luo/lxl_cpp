
---@class AppStateLogin:AppStateBase
AppStateLogin = AppStateLogin or class("AppStateLogin", AppStateBase)

function AppStateLogin:ctor(state_mgr, app)
    AppStateLogin.super.ctor(self, state_mgr, App_State_Name.login, app)
end

function AppStateLogin:on_enter(params)
    AppStateLogin.super.on_enter(self, params)
    self._is_all_done = false
    if not self.app.net_mgr.game_platform_net:is_ready() then
        self.app.panel_mgr:open_panel(UI_Panel_Name.platform_panel, {})
    else
        if not self.app.net_mgr.game_login_net:is_ready() then
            self.app.panel_mgr:open_panel(UI_Panel_Name.login_panel, {})
        end
    end
    self.event_binder:bind(self.app.net_mgr, Game_Net_Event.platform_ready_change,  Functional.make_closure(self._on_event_platform_login_done, self))
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
    self.app.panel_mgr:release_panel(UI_Panel_Name.platform_panel)
end

function AppStateLogin:is_all_done()
    local ret = self.app.net_mgr.game_platform_net:is_ready() and self.app.net_mgr.game_login_net:is_ready()
    return ret
end

function AppStateLogin:_on_event_platform_login_done(is_ready, error_msg)
    if is_ready then
        self.app.panel_mgr:release_panel(UI_Panel_Name.platform_panel, {})
        self.app.panel_mgr:open_panel(UI_Panel_Name.login_panel, {})
    end
end
