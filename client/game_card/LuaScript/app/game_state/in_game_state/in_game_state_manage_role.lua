
---@class InGameStateManageRole:InGameStateBase
InGameStateManageRole = InGameStateManageRole or class("InGameStateManageRole", InGameStateBase)

function InGameStateManageRole:ctor(state_mgr, in_game_state)
    InGameStateManageRole.super.ctor(self, state_mgr, In_Game_State_Name.manage_role, in_game_state)
    self.launch_error_num = nil
    -- self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
end


function InGameStateManageRole:on_enter(params)
    InGameStateManageRole.super.on_enter(self, params)
    --self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.open, Functional.make_closure(self._on_event_gate_cnn_open, self))
    --self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.close, Functional.make_closure(self._on_event_gate_cnn_close, self))
    --self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.login_gate_result, Functional.make_closure(self._on_event_login_gate_result, self))
    --
    --self.event_subscriber:subscribe(Game_User_Event.launch_role_result, Functional.make_closure(self._on_event_launch_role_result, self))
    --self.launch_error_num = nil
    --
    --local user_info = self.main_logic.main_user.user_info
    --self.main_logic.gate_cnn_logic:set_user_info(user_info.gate_ip, user_info.gate_port, user_info.user_id,
    --        user_info.auth_sn, user_info.auth_ip, user_info.auth_port, user_info.account_id, user_info.app_id)
    --self.main_logic.gate_cnn_logic:connect()
    --
    --self.app.panel_mgr:show_panel(UI_Panel_Name.launch_role_panel, user_info)
end

function InGameStateManageRole:on_update()
    InGameStateManageRole.super.on_update(self)
    --self.app.gate_cnn_logic:update()
    --if Error_None == self.launch_error_num then
    --    self.state_mgr:change_state(In_Game_State_Name.run, nil)
    --end
end

function InGameStateManageRole:on_exit()
    InGameStateManageRole.super.on_exit(self)
    --self.event_subscriber:release_all()
    --self.in_game_state.app.panel_mgr:release_panel(UI_Panel_Name.launch_role_panel)
end
--
--function InGameStateManageRole:_on_event_gate_cnn_open(cnn_logic, is_succ)
--    -- todo:
--end
--
--function InGameStateManageRole:_on_event_gate_cnn_close(cnn_logic, error_num, error_msg)
--    -- todo:
--end
--
--function InGameStateManageRole:_on_event_login_gate_result(cnn_logic, error_num)
--    if Error_None == error_num then
--        self.app.main_user:pull_role_digest()
--    end
--end
--
--
--function InGameStateManageRole:_on_event_launch_role_result(error_num)
--    log_debug("InGameStateManageRole:_on_event_launch_role_result %s", msg)
--    self.launch_error_num = error_num
--end