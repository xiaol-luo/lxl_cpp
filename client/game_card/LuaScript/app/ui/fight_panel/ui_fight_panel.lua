
---@class UIFightPanel:UIPanelBase
UIFightPanel = UIFightPanel or class("UIFightPanel", UIPanelBase)

function UIFightPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    ---@type GameTwoDice
    self._game_play = nil
    ---@type FightData
    self._fight_data = nil
    ---@type FightLogic
    self._fight_logic = nil
    self._event_binder = EventBinder:new()
    self._game_play_event_binder = EventBinder:new()
end

function UIFightPanel:_on_init()
    UIFightPanel.super._on_init(self)
end

function UIFightPanel:_on_attach_panel()
    UIFightPanel.super._on_attach_panel(self)
    ---@type UIButton
    self._close_btn = UIHelp.attach_ui(UIButton, self._panel_root, "close_btn")
    self._close_btn:set_onclick(Functional.make_closure(self._on_click_close_btn, self))

    ---@type UIButton
    self._bind_fight_btn = UIHelp.attach_ui(UIButton, self._panel_root, "main_content/bind_fight_view/bind_fight_btn")
    self._bind_fight_btn:set_onclick(Functional.make_closure(self._on_click_bind_fight_btn, self))

    ---@type UIButton
    self._quit_fight_btn = UIHelp.attach_ui(UIButton, self._panel_root, "main_content/bind_fight_view/quit_fight_btn")
    self._quit_fight_btn:set_onclick(Functional.make_closure(self._on_click_quit_fight_btn, self))

    ---@type UIButton
    self._roll_btn = UIHelp.attach_ui(UIButton, self._panel_root, "main_content/fight_view/roll_btn")
    self._roll_btn:set_onclick(Functional.make_closure(self._on_click_roll_btn, self))
    self._roll_btn:set_active(false)

    ---@type UIText
    self._bind_fight_state_txt = UIHelp.attach_ui(UIText, self._panel_root, "main_content/bind_fight_view/bind_fight_state")
    ---@type UIText
    self._round_txt = UIHelp.attach_ui(UIText, self._panel_root, "main_content/fight_view/roll_point")
    ---@type UIText
    self._roll_txt = UIHelp.attach_ui(UIText, self._panel_root, "main_content/fight_view/round")
    ---@type UIText
    self._log_txt = UIHelp.attach_ui(UIText, self._panel_root, "main_content/fight_log_view/log_detail")

    self._event_binder:bind(self._fight_data, Fight_Data_Event.bind_fight_state_change,
            Functional.make_closure(self._on_event_bind_fight_state_change, self))
end

function UIFightPanel:_on_open(panel_data)
    self._game_play = panel_data
    self._fight_data = self.app.data_mgr.fight
    self._fight_logic = self.app.logic_mgr.fight
    self._game_play_event_binder:release_all()
end

function UIFightPanel:_on_show_panel()
    self:_update_view()
end

function UIFightPanel:_update_view()
    local show_bind_fight_btn = true
    if Bind_Fight_State.binding == self._fight_data.bind_fight_state
        or Bind_Fight_State.ready == self._fight_data.bind_fight_state
    then
        show_bind_fight_btn = false
    end
    self._bind_fight_btn:set_active(show_bind_fight_btn)
    self._roll_btn:set_active(self._game_play)
end

function UIFightPanel:_on_release()
    self._event_binder:release_all()
    self._game_play_event_binder:release_all()
end

function UIFightPanel:_on_event_bind_fight_state_change(bind_fight_state, fight_key)
    self:_update_view()
end

function UIFightPanel:_on_click_close_btn()
    self.app.panel_mgr:close_panel(UI_Panel_Name.fight_panel)
    self.app.logic_mgr.fight:exit_fight()
end

function UIFightPanel:_on_click_bind_fight_btn()
    if Bind_Fight_State.ready ~= self.app.data_mgr.fight.bind_fight_state then
        self.app.data_mgr.fight:bind_fight()
    end
end

function UIFightPanel:_on_click_quit_fight_btn()
    self.app.logic_mgr.fight:exit_fight()
end

function UIFightPanel:_on_click_roll_btn()
    if self._game_play then
        self._game_play:req_roll()
    end
end












