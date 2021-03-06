
---@class GameTwoDice:GamePlayBase
GameTwoDice = GameTwoDice or class("GameTwoDice", GamePlayBase)

function GameTwoDice:ctor(fight_logic, game_name)
    GameTwoDice.super.ctor(self, fight_logic, game_name)
    self._update_tid = nil
    self.app = self.fight_logic.app
    self._fight_data = self.app.data_mgr.fight
    self._fight_logic = self.app.logic_mgr.fight
    self.main_role_id = self.app.data_mgr.main_role:get_role_id()


    self.fight_full_state = nil
    self.fight_brief_state = nil
    self.curr_round_data = nil

    self.fight_state = Two_Dice_Fight_State.idle
    self.curr_round = 0
end

function GameTwoDice:_on_init(setup_data)
    self._event_binder:bind(self._fight_data, Fight_Data_Event.rsp_fight_opera,
            Functional.make_closure(self._on_msg_rsp_fight_opera, self))
    self._event_binder:bind(self.app.net_mgr, Fight_Pid.two_dice_sync_fight_state,
            Functional.make_closure(self._on_msg_sync_fight_state, self))
    self._event_binder:bind(self.app.net_mgr, Fight_Pid.two_dice_sync_brief_state,
            Functional.make_closure(self._on_msg_sync_brief_state, self))
    self._event_binder:bind(self.app.net_mgr, Fight_Pid.two_dice_sync_curr_round,
            Functional.make_closure(self._on_msg_sync_curr_round, self))
end

function GameTwoDice:_on_resume()
    log_print("GameTwoDice:_on_resume")
    self:check_show_fight_panel(true)
    self:notify_ready_to_fight()
    self:pull_state()
end

function GameTwoDice:_on_pause()

end

function GameTwoDice:_on_release()
    self:check_show_fight_panel(false)
end

function GameTwoDice:check_show_fight_panel(is_show)
    if not is_show then
        self.app.panel_mgr:close_panel(UI_Panel_Name.fight_panel)
    else
        if not self.app.panel_mgr:is_panel_enable(UI_Panel_Name.fight_panel) then
            self.app.panel_mgr:open_panel(UI_Panel_Name.fight_panel, self)
        end
    end
end

function GameTwoDice:req_roll()
    self.app.data_mgr.fight:req_fight_opera({
        unique_id = self:next_seq(),
        opera = Two_Dice_Opera.roll,
    })
end

function GameTwoDice:pull_state()
    self.app.data_mgr.fight:pull_fight_state()
end

function GameTwoDice:notify_ready_to_fight()
    self.app.data_mgr.fight:req_fight_opera({
        unique_id = self:next_seq(),
        opera = Two_Dice_Opera.notify_ready_to_fight,
    })
end

function GameTwoDice:_on_msg_rsp_fight_opera(msg)
    log_print("GameTwoDice:_on_msg_rsp_fight_opera", msg)
end

function GameTwoDice:_on_msg_sync_fight_state(pid, msg)
    log_print("GameTwoDice:_on_msg_sync_fight_state", pid, msg)
    self.fight_full_state = msg
    self:set_curr_round(self.fight_full_state.curr_round.round)
    self:set_fight_state(self.fight_full_state.fight_state)
    self:fire(Game_Two_Dice_Event.fight_data_change)
end

function GameTwoDice:_on_msg_sync_brief_state(pid, msg)
    log_print("GameTwoDice:_on_msg_sync_brief_state", pid, msg)
    self.fight_brief_state = msg
    self:set_curr_round(self.fight_brief_state.curr_round)
    self:set_fight_state(self.fight_brief_state.fight_state)
    self:fire(Game_Two_Dice_Event.fight_data_change)
end

function GameTwoDice:_on_msg_sync_curr_round(pid, msg)
    log_print("GameTwoDice:_on_msg_sync_curr_round", pid, msg)
    self.curr_round_data = msg
    self:set_curr_round(self.curr_round_data.round)
    self:fire(Game_Two_Dice_Event.fight_data_change)
end

function GameTwoDice:set_fight_state(fight_state)
    local old_val = self.fight_state
    self.fight_state = fight_state
    if self.fight_state ~= old_val then
        self:fire(Game_Two_Dice_Event.fight_state_change, self.fight_state)
    end
end

function GameTwoDice:set_curr_round(round)
    local old_val = self.curr_round
    self.curr_round = round
    if self.curr_round ~= old_val then
        self:fire(Game_Two_Dice_Event.curr_round_change, self.curr_round)
    end
end
