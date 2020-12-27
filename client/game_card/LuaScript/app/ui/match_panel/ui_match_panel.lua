
---@class UIMatchPanel:UIPanelBase
UIMatchPanel = UIMatchPanel or class("UIMatchPanel", UIPanelBase)

function UIMatchPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self._match_data = self._app.data_mgr.match
    self._room_data = self._app.data_mgr.room
end

function UIMatchPanel:_on_init()
    UIMatchPanel.super._on_init(self)
    log_debug("UIMatchPanel:_on_init")
end

function UIMatchPanel:_on_attach_panel()
    UIMatchPanel.super._on_attach_panel(self)
    log_debug("UIMatchPanel:_on_attach_panel")
    ---@type UIText
    self._match_state_txt = UIHelp.attach_ui(UIText, self._panel_root, "match_view/match_state/content")

    ---@type UIButton
    self._join_match_btn = UIHelp.attach_ui(UIButton, self._panel_root, "opera_btns/join_match")
    self._join_match_btn:set_onclick(Functional.make_closure(self._on_click_join_match_btn, self))
    ---@type UIButton
    self._quit_match_btn = UIHelp.attach_ui(UIButton, self._panel_root, "opera_btns/quit_match")
    self._quit_match_btn:set_onclick(Functional.make_closure(self._on_click_quit_match_btn, self))
    ---@type UIButton
    self._query_btn = UIHelp.attach_ui(UIButton, self._panel_root, "opera_btns/query")
    self._query_btn:set_onclick(Functional.make_closure(self._on_click_query_btn, self))
    ---@type UIButton
    self._close_btn = UIHelp.attach_ui(UIButton, self._panel_root, "close_btn")
    self._close_btn:set_onclick(Functional.make_closure(self._on_click_close_btn, self))

    -- Bind Event
    self._event_binder:bind(self._match_data, Match_Data_Event.match_state_change,
            Functional.make_closure(self._on_event_match_state_change, self))

    self._event_binder:bind(self._room_data, Room_Data_Event.room_start, Functional.make_closure(self._on_event_room_start, self))

    self:_update_view()
end

function UIMatchPanel:_update_view()
    local match_txt = string.format("match_theme%s\n match_key:%s\n match_state:%s\n",
            self._match_data.match_theme, self._match_data.match_key, self._match_data.state)
    self._match_state_txt:set_text(match_txt)
end

function UIMatchPanel:_on_click_join_match_btn()
    self._app.data_mgr.match:req_join_match(Match_Theme.two_dice, {})
end

function UIMatchPanel:_on_click_quit_match_btn()
    self._app.data_mgr.match:req_quit_match()
end

function UIMatchPanel:_on_click_query_btn()
    self._app.data_mgr.match:pull_match_state()
end

function UIMatchPanel:_on_click_close_btn()
    self:_on_click_quit_match_btn()
    self._app.panel_mgr:close_panel(UI_Panel_Name.match_panel)
end

function UIMatchPanel:_on_event_match_state_change()
    self:_update_view()
end

function UIMatchPanel:_on_event_room_start()
    self._panel_mgr:close_panel(UI_Panel_Name.match_panel)
    self._panel_mgr:open_panel(UI_Panel_Name.room_panel, {})
end










