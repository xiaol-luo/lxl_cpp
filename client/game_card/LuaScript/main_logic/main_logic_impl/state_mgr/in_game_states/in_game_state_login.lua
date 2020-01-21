
InGameStateLogin = InGameStateLogin or class("InGameStateLogin", InGameStateBase)

function InGameStateLogin:ctor(state_mgr, in_game_state)
    InGameStateLogin.super.ctor(self, state_mgr, In_Game_State_Name.login, in_game_state)
    self.launch_error_num = nil
    self.user_info = nil
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
end


function InGameStateLogin:on_enter(params)
    InGameStateLogin.super.on_enter(self, params)
    self.launch_error_num = nil
    self.user_info = nil
    self.main_logic.login_cnn_logic:reset("", 0)
    self.event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.login_done, Functional.make_closure(self._on_event_login_cnn_done, self))
    self.in_game_state.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.login_panel, {})
end

function InGameStateLogin:on_update()
    InGameStateLogin.super.on_update(self)
    self.main_logic.login_cnn_logic:update()
    if Error_None == self.launch_error_num then
        self.state_mgr:change_state(In_Game_State_Name.launch_role, self.user_info)
    end
end

function InGameStateLogin:on_exit()
    InGameStateLogin.super.on_exit(self)
    self.event_subscriber:release_all()
    self.in_game_state.main_logic.ui_panel_mgr:release_panel(UI_Panel_Name.login_panel)
end

function InGameStateLogin:_on_event_login_cnn_done(cnn_logic, error_num, user_info)
    log_info("InGameStateLogin:_on_event_login_cnn_done")
    self.launch_error_num = error_num
    self.user_info = user_info
end
