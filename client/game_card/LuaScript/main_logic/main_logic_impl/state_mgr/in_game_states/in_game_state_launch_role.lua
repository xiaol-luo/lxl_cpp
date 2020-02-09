InGameStateLaunchRole = InGameStateLaunchRole or class("InGameStateLaunchRole", InGameStateBase)

function InGameStateLaunchRole:ctor(state_mgr, in_game_state)
    InGameStateLaunchRole.super.ctor(self, state_mgr, In_Game_State_Name.launch_role, in_game_state)
    self.launch_error_num = nil
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
end


function InGameStateLaunchRole:on_enter(params)
    InGameStateLaunchRole.super.on_enter(self, params)
    self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.login_gate_result, Functional.make_closure(self._on_event_login_gate_result, self))
    self.event_subscriber:subscribe(Event_Set__Main_User.launch_role_result, Functional.make_closure(self._on_event_launch_role_result, self))
    self.launch_error_num = nil

    local user_info = self.main_logic.main_user.user_info
    self.main_logic.gate_cnn_logic:set_user_info(user_info.gate_ip, user_info.gate_port, user_info.user_id,
            user_info.auth_sn, user_info.auth_ip, user_info.auth_port, user_info.account_id, user_info.app_id)
    self.main_logic.gate_cnn_logic:connect()

    self.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.launch_role_panel, user_info)
end

function InGameStateLaunchRole:on_update()
    InGameStateLaunchRole.super.on_update(self)
    self.main_logic.gate_cnn_logic:update()
    if Error_None == self.launch_error_num then
        self.state_mgr:change_state(In_Game_State_Name.run, nil)
    end
end

function InGameStateLaunchRole:on_exit()
    InGameStateLaunchRole.super.on_exit(self)
    self.event_subscriber:release_all()
    self.in_game_state.main_logic.ui_panel_mgr:release_panel(UI_Panel_Name.launch_role_panel)
end

function InGameStateLaunchRole:_on_event_login_gate_result(cnn_logic, error_num)
    if Error_None == error_num then
        self.main_logic.main_user:pull_role_digest()
    end
end


function InGameStateLaunchRole:_on_event_launch_role_result(error_num)
    log_debug("InGameStateLaunchRole:_on_event_launch_role_result %s", msg)
    self.launch_error_num = error_num
end