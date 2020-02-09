
UIMainPanel = UIMainPanel or class("UIMainPanel", UIPanelBase)

function UIMainPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self.panel_data = nil
    self.ml_event_subscriber = nil
end

function UIMainPanel:init()
    log_debug("UIMainPanel:init")
    self.super.init(self)
    self.ml_event_subscriber = g_ins.event_mgr:create_subscriber()
    self.query_btn = nil
    self.join_match_btn = nil
    self.quit_match_btn = nil
    self.user_id_txt = nil
    self.role_id_txt = nil
    self.role_name_txt = nil
    self.match_msg_txt = nil
    self.room_msg_txt = nil
end

function UIMainPanel:on_show(is_new_show, panel_data)
    self.panel_data = panel_data
    self.ml_event_subscriber:subscribe(ProtoId.sync_role_data, Functional.make_closure(self._on_msg_sync_role_data, self))
    self.ml_event_subscriber:subscribe(ProtoId.rsp_join_match, Functional.make_closure(self._on_msg_rsp_join_match, self))
    self.ml_event_subscriber:subscribe(ProtoId.sync_match_state, Functional.make_closure(self._on_msg_sync_match_state, self))
    self.ml_event_subscriber:subscribe(ProtoId.rsp_quit_match, Functional.make_closure(self._on_msg_rsp_quit_match, self))
    self.ml_event_subscriber:subscribe(ProtoId.sync_room_state, Functional.make_closure(self._on_msg_sync_room_state, self))
    self.ml_event_subscriber:subscribe(ProtoId.sync_remote_room_state, Functional.make_closure(self._on_msg_sync_remote_room_state, self))

    self.query_btn = UIHelp.attach_ui(UIButton, self.root_go, "QueryBtn")
    self.query_btn:set_onclick(Functional.make_closure(self._on_click_query_btn, self))

    self.join_match_btn = UIHelp.attach_ui(UIButton, self.root_go, "MatchView/JoinMatch")
    self.join_match_btn:set_onclick(Functional.make_closure(self._on_click_join_match_btn, self))

    self.quit_match_btn = UIHelp.attach_ui(UIButton, self.root_go, "MatchView/QuitMatch")
    self.quit_match_btn:set_onclick(Functional.make_closure(self._on_click_quit_match_btn, self))

    self.role_id_txt = UIHelp.attach_ui(UIText, self.root_go, "RoleID")
    self.role_name_txt = UIHelp.attach_ui(UIText, self.root_go, "RoleName")
    self.match_msg_txt = UIHelp.attach_ui(UIText, self.root_go, "MatchView/MatchMsg")
    self.room_msg_txt = UIHelp.attach_ui(UIText, self.root_go, "MatchView/RoomMsg")
end

function UIMainPanel:_on_click_query_btn()
    g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_role_data, { pull_type = 0 })
    g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_match_state)
    g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_room_state)
    g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_remote_room_state)
end

function UIMainPanel:_on_click_join_match_btn()
    g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.req_join_match, { match_type = 1 })
end

function UIMainPanel:_on_click_quit_match_btn()
    g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.req_quit_match, {  })
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
end

function UIMainPanel:_on_msg_sync_remote_room_state(proto_id, msg)
    self:refresh_ui()
end

function UIMainPanel:refresh_ui()
    self.role_id_txt:set_text(g_ins.main_role.role_id)
    self.role_name_txt:set_text(g_ins.main_role.role_name)
    self.match_msg_txt:set_text(string.format("match msg : %s", string.toprint(g_ins.main_role.data_match_msg)))
    self.room_msg_txt:set_text(string.format("room_msg : %s", string.toprint(g_ins.main_role.data_room_msg)))
end










