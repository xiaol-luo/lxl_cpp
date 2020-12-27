
---@class UIRoomPanel:UIPanelBase
UIRoomPanel = UIRoomPanel or class("UIRoomPanel", UIPanelBase)

function UIRoomPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self._match_data = self._app.data_mgr.match
    ---@type RoomData
    self._room_data = self._app.data_mgr.room
    ---@type FightData
    self._fight_data = self._app.data_mgr.fight
end

function UIRoomPanel:_on_init()
    UIRoomPanel.super._on_init(self)
    log_debug("UIRoomPanel:_on_init")
end

function UIRoomPanel:_on_attach_panel()
    UIRoomPanel.super._on_attach_panel(self)
    log_debug("UIRoomPanel:_on_attach_panel")
    ---@type UIText
    self._match_theme_content_txt = UIHelp.attach_ui(UIText, self._panel_root, "view/room_state/match_theme/content")
    ---@type UIText
    self._room_key_content_txt = UIHelp.attach_ui(UIText, self._panel_root, "view/room_state/room_key/content")
    ---@type UIText
    self._room_state_content_txt = UIHelp.attach_ui(UIText, self._panel_root, "view/room_state/room_state/content")
    ---@type UIText
    self._remote_room_state_content_txt = UIHelp.attach_ui(UIText, self._panel_root, "view/room_state/remote_room_state/content")
    ---@type UIText
    self._fight_key_content_txt = UIHelp.attach_ui(UIText, self._panel_root, "view/room_state/fight_key/content")
    ---@type UIText
    self._fight_host_content_txt = UIHelp.attach_ui(UIText, self._panel_root, "view/room_state/fight_host/content")

    ---@type UIButton
    self._join_match_btn = UIHelp.attach_ui(UIButton, self._panel_root, "view/opera_btns/enter_fight")
    self._join_match_btn:set_onclick(Functional.make_closure(self._on_click_enter_fight_btn, self))
    ---@type UIButton
    self._query_btn = UIHelp.attach_ui(UIButton, self._panel_root, "view/opera_btns/query")
    self._query_btn:set_onclick(Functional.make_closure(self._on_click_query_btn, self))
    ---@type UIButton
    self._close_btn = UIHelp.attach_ui(UIButton, self._panel_root, "close_btn")
    self._close_btn:set_onclick(Functional.make_closure(self._on_click_close_btn, self))

    -- Bind Event
    self._event_binder:bind(self._room_data, Room_Data_Event.room_state_change,
            Functional.make_closure(self._on_event_room_state_change, self))

    self:_update_view()
end

function UIRoomPanel:_update_view()
    self._match_theme_content_txt:set_text(self._room_data.match_theme)
    self._room_key_content_txt:set_text(self._room_data.room_key)
    self._room_state_content_txt:set_text(self._room_data.state)
    self._remote_room_state_content_txt:set_text(self._room_data.remote_room_state)
    self._fight_key_content_txt:set_text(self._room_data.fight_data.fight_key)
    self._fight_host_content_txt:set_text(string.format("%s:%s", self._room_data.fight_data.ip, self._room_data.fight_data.port))
end

function UIRoomPanel:_on_click_enter_fight_btn()
    self._app.state_mgr:change_in_game_state(In_Game_State_Name.fight, {})
end

function UIRoomPanel:_on_click_query_btn()
    self._room_data:pull_room_state()
end

function UIRoomPanel:_on_click_close_btn()
    self._app.panel_mgr:close_panel(UI_Panel_Name.room_panel)
end

function UIRoomPanel:_on_event_room_state_change()
    self:_update_view()
end










