
---@class UIFightPanel:UIPanelBase
UIFightPanel = UIFightPanel or class("UIFightPanel", UIPanelBase)

function UIFightPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self._main_role = self._app.data_mgr.main_role
end

function UIFightPanel:_on_init()
    UIFightPanel.super._on_init(self)
    log_debug("UIFightPanel:_on_init")
end

function UIFightPanel:_on_attach_panel()
    UIFightPanel.super._on_attach_panel(self)
    log_debug("UIFightPanel:_on_attach_panel")
    ---@type UIText
    self._role_state_txt = UIHelp.attach_ui(UIText, self._panel_root, "match_view/infos/match_state/content")
    ---@type UIText
    self._room_state_txt = UIHelp.attach_ui(UIText, self._panel_root, "match_view/infos/room_state/content")
    ---@type UIText
    self._fight_state_txt = UIHelp.attach_ui(UIText, self._panel_root, "match_view/infos/fight_state/content")

    ---@type UIButton
    self._join_match_btn = UIHelp.attach_ui(UIButton, self._panel_root, "match_view/opera_btns/join_match")
    self._join_match_btn:set_onclick(Functional.make_closure(self._on_click_join_match_btn, self))
    ---@type UIButton
    self._quit_match_btn = UIHelp.attach_ui(UIButton, self._panel_root, "match_view/opera_btns/quit_match")
    self._quit_match_btn:set_onclick(Functional.make_closure(self._on_click_quit_match_btn, self))
    ---@type UIButton
    self._query_btn = UIHelp.attach_ui(UIButton, self._panel_root, "match_view/opera_btns/query")
    self._query_btn:set_onclick(Functional.make_closure(self._on_click_query_btn, self))

    ---@type UIButton
    self._close_btn = UIHelp.attach_ui(UIButton, self._panel_root, "close_btn")
    self._close_btn:set_onclick(Functional.make_closure(self._on_click_close_btn, self))

    -- self._event_binder:bind(self._main_role, Main_Role_Event.sync_role_data, Functional.make_closure(self._on_event_sync_role_data, self))

    self:_update_match_view()
end

function UIFightPanel:_update_match_view()
end

function UIFightPanel:_on_click_join_match_btn()
    self._app.data_mgr.match:req_join_match(Match_Theme.two_dice, {})
end

function UIFightPanel:_on_click_quit_match_btn()
    self._app.data_mgr.match:req_quit_match()
end

function UIFightPanel:_on_click_query_btn()
    self._app.data_mgr.match:pull_match_state()
end

function UIFightPanel:_on_click_close_btn()
    self:_on_click_quit_match_btn()
    self._app.panel_mgr:close_panel(UI_Panel_Name.match_panel)
    self._app.state_mgr.in_game_state_mgr:change_state(In_Game_State_Name.in_lobby, {})
end










