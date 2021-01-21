
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

    ---@type UIButton
    self._pull_btn = UIHelp.attach_ui(UIButton, self._panel_root, "main_content/fight_view/pull_btn")
    self._pull_btn:set_onclick(Functional.make_closure(self._on_click_pull_btn, self))
    self._pull_btn:set_active(false)

    ---@type UIText
    self._bind_fight_state_txt = UIHelp.attach_ui(UIText, self._panel_root, "main_content/bind_fight_view/bind_fight_state")
    ---@type UIText
    self._round_txt = UIHelp.attach_ui(UIText, self._panel_root, "main_content/fight_view/round")
    ---@type UIText
    self._roll_point_txt = UIHelp.attach_ui(UIText, self._panel_root, "main_content/fight_view/roll_point")
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

    log_print("UIFightPanel:_on_open", self._on_event_curr_round_change)
    self._game_play_event_binder:bind(self._game_play, Game_Two_Dice_Event.curr_round_change,
            Functional.make_closure(self._on_event_curr_round_change, self))
    self._game_play_event_binder:bind(self._game_play, Game_Two_Dice_Event.fight_state_change,
            Functional.make_closure(self._on_event_fight_state_change, self))
    self._game_play_event_binder:bind(self._game_play, Game_Two_Dice_Event.fight_data_change,
            Functional.make_closure(self._on_event_fight_data_change, self))

    self._game_play:pull_state()
end

function UIFightPanel:_on_show_panel()
    self:_update_view()
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
        -- self._game_play:notify_ready_to_fight()
        self._game_play:req_roll()
        self._game_play:pull_state()
    end
end

function UIFightPanel:_on_click_pull_btn()
    if self._game_play then
        self._game_play:pull_state()
    end
end

function UIFightPanel:_on_event_curr_round_change(curr_round)
    -- self:_update_view()
end

function UIFightPanel:_on_event_fight_state_change(fight_state)
    -- self:_update_view()
end

function UIFightPanel:_on_event_fight_data_change()
    self:_update_view()
end

function UIFightPanel:_update_view()
    local show_bind_fight_btn = true
    if Bind_Fight_State.binding == self._fight_data.bind_fight_state
            or Bind_Fight_State.ready == self._fight_data.bind_fight_state
    then
        show_bind_fight_btn = false
    end

    self._bind_fight_state_txt:set_text(string.format("state: %s", self._fight_data.bind_fight_state))

    self._bind_fight_btn:set_active(show_bind_fight_btn)
    self._roll_btn:set_active(self._game_play)
    self._pull_btn:set_active(self._game_play)

    if not self._game_play then
        return
    end

    self._round_txt:set_text(self._game_play.curr_round)
    local roll_point = 0
    if self._game_play.curr_round_data then
        for _, elem in pairs(self._game_play.curr_round_data.roll_results or {}) do
            if elem.role_id == self._game_play.main_role_id then
                roll_point = elem.roll_point
                break
            end
        end
    end
    self._roll_point_txt:set_text(roll_point)

    local log_str_list = {}
    if self._game_play.fight_full_state then
        for _, round in ipairs(self._game_play.fight_full_state.history_rounds or {}) do
            local win_role_id = 0
            local win_point = 0
            local round_str_list = {}
            for _, roll_result in ipairs(round.roll_results or {}) do
                table.insert(round_str_list, string.format("%s->%s", roll_result.role_id, roll_result.roll_point))
                if roll_result.roll_point > win_point then
                    win_role_id = roll_result.role_id
                    win_point = roll_result.roll_point
                end
            end
            table.insert(log_str_list, string.format("round:%s -- winner:%s->%s -- full_info:%s", round.round, win_role_id, win_point, table.concat(round_str_list, ";")))
        end
    end
    self._log_txt:set_text(table.concat(log_str_list, "\n"))
end











