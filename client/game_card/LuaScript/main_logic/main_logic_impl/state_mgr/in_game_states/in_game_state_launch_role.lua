InGameStateLaunchRole = InGameStateLaunchRole or class("InGameStateLaunchRole", InGameStateBase)

function InGameStateLaunchRole:ctor(state_mgr, in_game_state)
    InGameStateLaunchRole.super.ctor(self, state_mgr, In_Game_State_Name.launch_role, in_game_state)
    self.user_info = nil
    self.launch_error_num = nil
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
end


function InGameStateLaunchRole:on_enter(params)
    InGameStateLaunchRole.super.on_enter(self, params)
    self.user_info = params
    self.main_logic.gate_cnn_logic:reset(self.user_info.gate_ip, self.user_info.gate_port)
    g_ins.gate_cnn_logic:set_user_info(self.user_info.gate_ip, self.user_info.gate_port, self.user_info.user_id,
            self.user_info.auth_sn, self.user_info.auth_ip, self.user_info.auth_port, self.user_info.account_id, self.user_info.app_id)
    self.main_logic.gate_cnn_logic:connect()
    self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.rsp_launch_role, Functional.make_closure(self._on_event_rsp_launch_role, self))
    self.in_game_state.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.launch_role_panel, self.user_info)
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

function InGameStateLaunchRole:_on_event_rsp_launch_role(cnn_logic, msg)
    log_debug("InGameStateLaunchRole:_on_event_rsp_launch_role %s", msg)
    self.launch_error_num = msg.error_num
end