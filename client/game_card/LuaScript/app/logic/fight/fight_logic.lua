
---@class FightLogic:LogicBase
FightLogic = FightLogic or class("FightLogic", LogicBase)

function FightLogic:ctor(logic_mgr)
    FightLogic.super.ctor(self, logic_mgr, "fight")
    ---@type RoomData
    self._room_data = nil
    self._fight_data = nil
    self.curr_room_key = nil
    self.curr_fight_key = nil
    ---@type GamePlayBase
    self._game_play = nil
end

function FightLogic:_on_start()
    log_print("======= FightLogic:_on_start", self.app)
    FightLogic.super._on_start(self)

    self._room_data = self.app.data_mgr.room
    self._fight_data = self.app.data_mgr.fight

    self._event_binder:bind(self._room_data, Room_Data_Event.ask_enter_room,
            Functional.make_closure(self._on_event_ask_enter_room, self))
    self._event_binder:bind(self._room_data, Room_Data_Event.room_start,
            Functional.make_closure(self._on_event_room_start, self))
    self._event_binder:bind(self._room_data, Room_Data_Event.room_over,
            Functional.make_closure(self._on_event_room_over, self))
    self._event_binder:bind(self._room_data, Room_Data_Event.room_state_change,
            Functional.make_closure(self._on_event_room_change, self))

    self._event_binder:bind(self.app.state_mgr, In_Game_State_Event.enter_state,
            Functional.make_closure(self._on_event_in_game_state_enter, self))
    self._event_binder:bind(self.app.state_mgr, In_Game_State_Event.exit_state,
            Functional.make_closure(self._on_event_in_game_state_exit, self))

    self._event_binder:bind(self._fight_data, Fight_Data_Event.bind_fight_state_change,
            Functional.make_closure(self._on_event_bind_fight_state_change, self))
end

function FightLogic:_on_event_ask_enter_room(ev_data)
    ---@type UIMessageBoxData
    local msg_data = UIMessageBoxData:new()
    msg_data.str_content = "进入新的房间"
    msg_data.cb_refuse = Functional.make_closure(self._on_cb_choose_enter_room, self, ev_data, false)
    msg_data.cb_confirm = Functional.make_closure(self._on_cb_choose_enter_room, self, ev_data, true)
    self.app.ui_mgr.msg_box:add_msg_box(msg_data)
end

function FightLogic:_on_cb_choose_enter_room(ev_data, is_accept)
    self.app.net_mgr.game_gate_net:send_msg(Fight_Pid.rpl_svr_accept_enter_room, {
        room_key = ev_data.room_key,
        match_server_key = ev_data.match_server_key,
        is_accept = is_accept,
    })
    if is_accept then
        self:exit_fight()
        self._room_data:set_accepted_room_key(ev_data.room_key)
        self._room_data:pull_room_state()
    end
end

function FightLogic:_on_event_room_start(room_key)
    if self.curr_room_key ~= room_key then
        if self.app.state_mgr:in_state(App_State_Name.in_game, In_Game_State_Name.fight) then
            self.app.state_mgr:change_in_game_state(In_Game_State_Name.in_lobby)
        end
    end
    self.curr_room_key = room_key
    log_print("++++++++++++ FightLogic:_on_event_room_start", self.curr_room_key)
    if not self.app.panel_mgr:is_panel_enable(UI_Panel_Name.room_panel) then
        self.app.panel_mgr:open_panel(UI_Panel_Name.room_panel)
    end
end

function FightLogic:_on_event_room_over(room_key)
    if self.curr_room_key == room_key then
        self:exit_fight()
    end
end

function FightLogic:_on_event_room_change(room_key)
    if self.curr_room_key ~= room_key then
        return
    end
    if Room_State.in_fight == self._room_data.remote_room_state then
        self.app.ui_mgr.msg_box:show_confirm("enter fight", nil,
                Functional.make_closure(self.enter_fight, self, room_key,
                        self._room_data.fight_data.fight_key))
    end
end

function FightLogic:enter_fight(room_key, fight_key)
    if room_key == self.curr_room_key and nil == self.curr_fight_key then
        self.curr_fight_key = fight_key
        self._fight_data:set_accept_fight_key(self.curr_fight_key)
        self._fight_data:try_extract_fight_data()
        self.app.state_mgr:change_in_game_state(In_Game_State_Name.fight)
        self.app.data_mgr.fight:bind_fight()
        self:setup_game_play(true, self._fight_data.match_theme, {})
    end
end

function FightLogic:exit_fight()
    self.curr_fight_key = nil
    self.curr_room_key = nil
    self._room_data:set_accepted_room_key(nil)
    self._fight_data:unbind_fight()
    if self.app.state_mgr:in_state(App_State_Name.in_game, In_Game_State_Name.fight) then
        self.app.state_mgr:change_in_game_state(In_Game_State_Name.in_lobby)
    end
    self:setup_game_play(false, nil, nil)
end

function FightLogic:_on_event_in_game_state_enter(state_name, ev_param)
    self.app.panel_mgr:open_panel(UI_Panel_Name.fight_panel, {})
end

function FightLogic:_on_event_in_game_state_exit(state_name)
    self.app.panel_mgr:close_panel(UI_Panel_Name.fight_panel)
end

---@param bind_fight_state Bind_Fight_State
function FightLogic:_on_event_bind_fight_state_change(bind_fight_state, fight_key)
    if self.curr_fight_key ~= fight_key then
        return
    end
    if not self._game_play then
        return
    end
    if Bind_Fight_State.ready == bind_fight_state then
        log_print("FightLogic:_on_event_bind_fight_state_change resume")
        self._game_play:resume()
    else
        self._game_play:pause()
    end
end

function FightLogic:setup_game_play(is_setup, game_id, setup_data)
    if self._game_play then
        self._game_play:pause()
        self._game_play:release()
        self._game_play = nil
    end
    if not is_setup then
        return
    end
    if game_id == "two_dice" then
        self._game_play = GameTwoDice:new(self)
        self._game_play:init(setup_data)
        return
    end
    return nil
end







