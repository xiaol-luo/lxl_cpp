
---@class UIMainPanel:UIPanelBase
UIMainPanel = UIMainPanel or class("UIMainPanel", UIPanelBase)

function UIMainPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self.panel_data = nil
    self.ml_event_subscriber = nil
    self.query_btn = nil
    self.logout_btn = nil
    self.join_match_btn = nil
    self.quit_match_btn = nil
    self.user_id_txt = nil
    self.role_id_txt = nil
    self.role_name_txt = nil
    self.match_msg_txt = nil
    self.room_msg_txt = nil
    self.roll_btn = nil
    self.roll_msg_txt = nil
end

function UIMainPanel:_on_init()
    UIMainPanel.super._on_init(self)

    --self.panel_data = panel_data
    --self.ml_event_subscriber:subscribe(ProtoId.sync_role_data, Functional.make_closure(self._on_msg_sync_role_data, self))
    --self.ml_event_subscriber:subscribe(ProtoId.rsp_join_match, Functional.make_closure(self._on_msg_rsp_join_match, self))
    --self.ml_event_subscriber:subscribe(ProtoId.sync_match_state, Functional.make_closure(self._on_msg_sync_match_state, self))
    --self.ml_event_subscriber:subscribe(ProtoId.rsp_quit_match, Functional.make_closure(self._on_msg_rsp_quit_match, self))
    --self.ml_event_subscriber:subscribe(ProtoId.sync_room_state, Functional.make_closure(self._on_msg_sync_room_state, self))
    --self.ml_event_subscriber:subscribe(ProtoId.sync_remote_room_state, Functional.make_closure(self._on_msg_sync_remote_room_state, self))
    --self.ml_event_subscriber:subscribe(ProtoId.sync_roll_point_result, Functional.make_closure(self._on_msg_sync_roll_point_result, self))
end

function UIMainPanel:_on_attach_panel()
    UIMainPanel.super._on_attach_panel(self)
    log_debug("UIMainPanel:init")
    self.query_btn = UIHelp.attach_ui(UIButton, self._panel_root, "QueryBtn")
    self.query_btn:set_onclick(Functional.make_closure(self._on_click_query_btn, self))

    self.logout_btn = UIHelp.attach_ui(UIButton, self._panel_root, "LogoutBtn")
    self.logout_btn:set_onclick(Functional.make_closure(self._on_click_logout_btn))

    self.join_match_btn = UIHelp.attach_ui(UIButton, self._panel_root, "MatchView/JoinMatch")
    self.join_match_btn:set_onclick(Functional.make_closure(self._on_click_join_match_btn, self))

    self.quit_match_btn = UIHelp.attach_ui(UIButton, self._panel_root, "MatchView/QuitMatch")
    self.quit_match_btn:set_onclick(Functional.make_closure(self._on_click_quit_match_btn, self))

    self.role_id_txt = UIHelp.attach_ui(UIText, self._panel_root, "RoleID")
    self.role_name_txt = UIHelp.attach_ui(UIText, self._panel_root, "RoleName")
    self.match_msg_txt = UIHelp.attach_ui(UIText, self._panel_root, "MatchView/MatchMsg")
    self.room_msg_txt = UIHelp.attach_ui(UIText, self._panel_root, "MatchView/RoomMsg")

    self.roll_btn = UIHelp.attach_ui(UIButton, self._panel_root, "MatchView/RollBtn")
    self.roll_btn:set_onclick(Functional.make_closure(self._on_click_roll_btn, self))

    self.roll_msg_txt = UIHelp.attach_ui(UIText, self._panel_root, "MatchView/RollMsg")
end

function UIMainPanel:on_hide()
    -- self.ml_event_subscriber:release_all()
end

function UIMainPanel:_on_click_query_btn()
    --g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_role_data, { pull_type = 0 })
    --g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_match_state)
    --g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_room_state)
    --g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_remote_room_state)
end

function UIMainPanel:_on_click_logout_btn()
    -- g_ins.event_mgr:fire(Event_Set__State_InGame.try_enter_logout_state)
end

function UIMainPanel:_on_click_join_match_btn()
    -- g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.req_join_match, { match_type = 1 })
end

function UIMainPanel:_on_click_quit_match_btn()
    -- g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.req_quit_match, {  })
end

function UIMainPanel:_on_click_roll_btn()
    -- g_ins.fight_cnn_logic:send_msg(ProtoId.req_fight_opera, { opera = "roll" })
end

function UIMainPanel:_on_msg_sync_role_data(proto_id, msg)
    self:refresh_ui()
end

function UIMainPanel:_on_msg_rsp_join_match(proto_id, msg)
    self:refresh_ui()
end

function UIMainPanel:_on_msg_rsp_quit_match(proto_id, msg)
    self:refresh_ui()
end

function UIMainPanel:_on_msg_sync_match_state(proto_id, msg)
    self:refresh_ui()
end

function UIMainPanel:_on_msg_sync_room_state(proto_id, msg)
    self:refresh_ui()
    --if msg.state == 3 then
    --    log_debug("UIMainPanel:_on_msg_sync_room_state reach here")
    --    g_ins.fight_cnn_logic:set_fight_info(msg.fight_service_ip, msg.fight_service_port,
    --            msg.fight_battle_id, msg.fight_session_id, g_ins.main_role.role_id)
    --    g_ins.fight_cnn_logic:set_active(true)
    --else
    --    g_ins.fight_cnn_logic:set_active(false)
    --end
end

function UIMainPanel:_on_msg_sync_remote_room_state(proto_id, msg)
    self:refresh_ui()
end

function UIMainPanel:_on_msg_sync_roll_point_result(proto_id, msg)
    self:refresh_ui()
    self.roll_msg_txt:set_text(string.format("roll result: %s", string.to_print(msg)))
end

function UIMainPanel:refresh_ui()
    --self.role_id_txt:set_text(g_ins.main_role.role_id)
    --self.role_name_txt:set_text(g_ins.main_role.role_name)
    --self.match_msg_txt:set_text(string.format("match msg : %s", string.to_print(g_ins.main_role.data_match_msg)))
    --self.room_msg_txt:set_text(string.format("room_msg : %s", string.to_print(g_ins.main_role.data_room_msg)))
end










