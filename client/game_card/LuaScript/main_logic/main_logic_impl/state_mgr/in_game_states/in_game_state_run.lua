
InGameStateRun = InGameStateRun or class("InGameStateRun", InGameStateBase)

function InGameStateRun:ctor(state_mgr, in_game_state)
    InGameStateRun.super.ctor(self, state_mgr, In_Game_State_Name.run, in_game_state)
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
end

function InGameStateRun:on_enter(params)
    InGameStateRun.super.on_enter(self, params)
    self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.login_gate_result, Functional.make_closure(self._on_event_login_gate_result, self))
    self.event_subscriber:subscribe(Event_Set__Main_User.launch_role_result, Functional.make_closure(self._on_event_launch_role_result, self))

    self.main_logic.gate_cnn_logic:send_msg_to_game(ProtoId.pull_role_data, { pull_type = 0 })
    self.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.main_panel, {})
end

function InGameStateRun:on_update()
    InGameStateRun.super.on_update(self)
    self.main_logic.gate_cnn_logic:update()
end

function InGameStateRun:on_exit()
    InGameStateRun.super.on_exit(self)
end

function InGameStateRun:_on_event_login_gate_result(cnn_logic, error_num)
    -- do nothing
end

function InGameStateRun:_on_event_launch_role_result(error_num)
    log_debug("InGameStateRun:_on_event_rsp_launch_role %s", error_num)
    self.launch_error_num = error_num
end
