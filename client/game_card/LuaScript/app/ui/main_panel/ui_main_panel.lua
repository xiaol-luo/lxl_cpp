
---@class UIMainPanel:UIPanelBase
UIMainPanel = UIMainPanel or class("UIMainPanel", UIPanelBase)

function UIMainPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self._main_role = self._app.data_mgr.main_role
end

function UIMainPanel:_on_init()
    UIMainPanel.super._on_init(self)
    log_debug("UIMainPanel:_on_init")
end

function UIMainPanel:_on_attach_panel()
    UIMainPanel.super._on_attach_panel(self)
    log_debug("UIMainPanel:_on_attach_panel")
    ---@type UIText
    self._role_id_txt = UIHelp.attach_ui(UIText, self._panel_root, "role_view/base_info/role_id/content")
    ---@type UIText
    self._role_name_txt = UIHelp.attach_ui(UIText, self._panel_root, "role_view/base_info/role_name/content")
    ---@type UIButton
    self._logout_btn = UIHelp.attach_ui(UIButton, self._panel_root, "role_view/opera_btns/logout")
    self._logout_btn:set_onclick(Functional.make_closure(self._on_click_logout_btn, self))
    ---@type UIButton
    self._pick_role_btn = UIHelp.attach_ui(UIButton, self._panel_root, "role_view/opera_btns/pick_role")
    self._pick_role_btn:set_onclick(Functional.make_closure(self._on_click_pick_role_btn, self))
    ---@type UIButton
    self._query_role_btn = UIHelp.attach_ui(UIButton, self._panel_root, "role_view/opera_btns/query")
    self._query_role_btn:set_onclick(Functional.make_closure(self._on_click_query_role_btn, self))
    ---@type UIButton
    self._match_panel_btn = UIHelp.attach_ui(UIButton, self._panel_root, "function_view/line_1/match")
    self._match_panel_btn:set_onclick(Functional.make_closure(self._on_click_match_panel_btn, self))
    ---@type UIButton
    self.rank_panel_btn = UIHelp.attach_ui(UIButton, self._panel_root, "function_view/line_1/rank")
    self.rank_panel_btn:set_onclick(Functional.make_closure(self._on_click_rank_panel_btn, self))

    self._event_binder:bind(self._main_role, Main_Role_Event.sync_role_data, Functional.make_closure(self._on_event_sync_role_data, self))

    self:_update_role_view()
end

function UIMainPanel:_update_role_view()
    self._role_id_txt:set_text(self._main_role:get_role_id())
    self._role_name_txt:set_text(self._main_role:get_name())
end

function UIMainPanel:_on_click_query_role_btn()
    self._main_role:pull_role_data(0)
end

function UIMainPanel:_on_click_logout_btn()
    self._app.data_mgr.game_user:logout_role()
    self._app.net_mgr.game_platform_net:logout()
    self._app.net_mgr.game_login_net:logout()
    self._app.net_mgr.game_gate_net:disconnect()
    self._app.state_mgr:change_state(App_State_Name.login)
end

function UIMainPanel:_on_click_pick_role_btn()
    self._app.data_mgr.game_user:logout_role()
    self._app.net_mgr.game_gate_net:disconnect()
    self._app.state_mgr.in_game_state_mgr:change_state(In_Game_State_Name.manage_role)
end

function UIMainPanel:_on_click_match_panel_btn()
    -- g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.req_quit_match, {  })
end

function UIMainPanel:_on_click_rank_panel_btn()
    -- g_ins.fight_cnn_logic:send_msg(ProtoId.req_fight_opera, { opera = "roll" })
end

function UIMainPanel:_on_event_sync_role_data(main_role)
    self:_update_role_view()
end










