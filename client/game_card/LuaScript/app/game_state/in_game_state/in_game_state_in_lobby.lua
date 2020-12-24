
---@class InGameStateInLobby:InGameStateBase
InGameStateInLobby = InGameStateInLobby or class("InGameStateInLobby", InGameStateBase)

function InGameStateInLobby:ctor(state_mgr, in_game_state)
    InGameStateInLobby.super.ctor(self, state_mgr, In_Game_State_Name.in_lobby, in_game_state)
    -- self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
    self.gate_last_reconnect_sec = 0
    self.fight_last_reconnect_sec = 0
end

function InGameStateInLobby:on_enter(params)
    InGameStateInLobby.super.on_enter(self, params)
    self.app.panel_mgr:open_panel(UI_Panel_Name.main_panel, {})
end

function InGameStateInLobby:on_update()
    InGameStateInLobby.super.on_update(self)
end

function InGameStateInLobby:on_exit()
    InGameStateInLobby.super.on_exit(self)
    self.app.panel_mgr:close_all_panel()
end
--
--function InGameStateInLobby:_on_event_gate_cnn_open(cnn_logic, is_succ)
--    -- todo:
--end
--
--function InGameStateInLobby:_on_event_gate_cnn_close(cnn_logic, error_num, error_msg)
--    -- todo:
--end
--
--function InGameStateInLobby:_on_event_login_gate_result(cnn_logic, error_num)
--    if Error_None == error_num then
--        -- login_gate 成功了， launch_role之前选择的role_id
--        if self.main_logic.main_role.role_id then
--            self.main_logic.main_user:launch_role(self.main_logic.main_role.role_id)
--        end
--    else
--        -- login_gate 失败了， 回去登录界面
--        self.main_logic.event_mgr:fire(Event_Set__State_InGame.try_enter_logout_state)
--    end
--end
--
--function InGameStateInLobby:_on_event_relogin_gate_result(cnn_logic, error_num)
--    -- todo: 重连失败，那么尝试直接login_gate
--    if Error_None ~= error_num then
--        self.main_logic.gate_cnn_logic:login_gate(false)
--    end
--end
--
--function InGameStateInLobby:_on_event_launch_role_result(error_num)
--    -- launch_role失败，还是回去登录界面吧
--    log_debug("InGameStateInLobby:_on_event_rsp_launch_role %s", error_num)
--    if Error_None ~= error_num then
--        self.main_logic.event_mgr:fire(Event_Set__State_InGame.try_enter_logout_state)
--    end
--end
