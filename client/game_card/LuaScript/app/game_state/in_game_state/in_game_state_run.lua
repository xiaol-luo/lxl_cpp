
---@class InGameStateRun:InGameStateBase
InGameStateRun = InGameStateRun or class("InGameStateRun", InGameStateBase)

function InGameStateRun:ctor(state_mgr, in_game_state)
    InGameStateRun.super.ctor(self, state_mgr, In_Game_State_Name.run, in_game_state)
    -- self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
    self.gate_last_reconnect_sec = 0
    self.fight_last_reconnect_sec = 0
end

function InGameStateRun:on_enter(params)
    InGameStateRun.super.on_enter(self, params)
    --self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.open, Functional.make_closure(self._on_event_gate_cnn_open, self))
    --self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.close, Functional.make_closure(self._on_event_gate_cnn_close, self))
    --self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.login_gate_result, Functional.make_closure(self._on_event_login_gate_result, self))
    --self.event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.relogin_gate_result, Functional.make_closure(self._on_event_relogin_gate_result, self))
    --self.event_subscriber:subscribe(Game_User_Event.launch_role, Functional.make_closure(self._on_event_launch_role_result, self))
    --
    --
    --self.main_logic.gate_cnn_logic:send_msg_to_game(ProtoId.pull_role_data, { pull_type = 0 })
    --self.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.main_panel, {})
    --self.gate_last_reconnect_sec = 0
    --self.fight_last_reconnect_sec = 0
end

function InGameStateRun:on_update()
    InGameStateRun.super.on_update(self)
    --self.main_logic.gate_cnn_logic:update()
    --local cnn_state = self.main_logic.gate_cnn_logic:get_state()
    --if Net_Agent_State.closed == cnn_state or Net_Agent_State.free == cnn_state then
    --    local now_sec = logic_sec()
    --    if now_sec - self.gate_last_reconnect_sec >= 10 then
    --       self.gate_last_reconnect_sec = now_sec
    --        self.main_logic.gate_cnn_logic:connect()
    --    end
    --end
    ---- log_debug("is_active = %s", self.main_logic.fight_cnn_logic:get_is_active())
    --if self.main_logic.fight_cnn_logic:get_is_active() then
    --    local cnn_state = self.main_logic.fight_cnn_logic:get_state()
    --    if Net_Agent_State.closed == cnn_state or Net_Agent_State.free == cnn_state then
    --        local now_sec = logic_sec()
    --        if now_sec - self.gate_last_reconnect_sec >= 3 then
    --            self.gate_last_reconnect_sec = now_sec
    --            self.main_logic.fight_cnn_logic:connect()
    --        end
    --    end
    --end
end

function InGameStateRun:on_exit()
    InGameStateRun.super.on_exit(self)
end
--
--function InGameStateRun:_on_event_gate_cnn_open(cnn_logic, is_succ)
--    -- todo:
--end
--
--function InGameStateRun:_on_event_gate_cnn_close(cnn_logic, error_num, error_msg)
--    -- todo:
--end
--
--function InGameStateRun:_on_event_login_gate_result(cnn_logic, error_num)
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
--function InGameStateRun:_on_event_relogin_gate_result(cnn_logic, error_num)
--    -- todo: 重连失败，那么尝试直接login_gate
--    if Error_None ~= error_num then
--        self.main_logic.gate_cnn_logic:login_gate(false)
--    end
--end
--
--function InGameStateRun:_on_event_launch_role_result(error_num)
--    -- launch_role失败，还是回去登录界面吧
--    log_debug("InGameStateRun:_on_event_rsp_launch_role %s", error_num)
--    if Error_None ~= error_num then
--        self.main_logic.event_mgr:fire(Event_Set__State_InGame.try_enter_logout_state)
--    end
--end
