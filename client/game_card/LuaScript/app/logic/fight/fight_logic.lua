
---@class FightLogic:LogicBase
FightLogic = FightLogic or class("FightLogic", LogicBase)

function FightLogic:ctor(logic_mgr)
    FightLogic.super.ctor(self, logic_mgr, "fight")
    ---@type RoomData
    self._room_data = nil
    self.curr_room_key = nil
end

function FightLogic:_on_init()
    self._room_data = self._app.data_mgr.room
    self._event_binder:bind(self._room_data, Room_Data_Event.ask_enter_room,
            Functional.make_closure(self._on_event_ask_enter_room, self))
    self._event_binder:bind(self._room_data, Room_Data_Event.room_start,
            Functional.make_closure(self._on_event_room_start, self))
    self._event_binder:bind(self._room_data, Room_Data_Event.room_start,
            Functional.make_closure(self._on_event_room_over, self))
    self._event_binder:bind(self._room_data, Room_Data_Event.room_start,
            Functional.make_closure(self._on_event_room_change, self))
end

function FightLogic:_on_event_ask_enter_room(ev_data)
    ---@type UIMessageBoxData
    local msg_data = UIMessageBoxData:new()
    msg_data.str_content = "进入新的房间"
    msg_data.cb_refuse = Functional.make_closure(self._on_cb_choose_enter_room, self, ev_data, false)
    msg_data.cb_confirm = Functional.make_closure(self._on_cb_choose_enter_room, self, ev_data, true)
    self._app.ui_mgr.msg_box:add_msg_box(msg_data)
end

function FightLogic:_on_cb_choose_enter_room(ev_data, is_accept)
    self._app.net_mgr.game_gate_net:send_msg(Fight_Pid.rpl_svr_accept_enter_room, {
        room_key = ev_data.room_key,
        match_server_key = ev_data.match_server_key,
        is_accept = is_accept,
    })
    if is_accept then
        self._room_data:set_accepted_room_key(ev_data.room_key)
    end
end

function FightLogic:_on_event_room_start(room_key)
    if self.curr_room_key ~= room_key then
        if self._app.state_mgr:in_state(App_State_Name.in_game, In_Game_State_Name.fight) then
            self._app.state_mgr:change_in_game_state(In_Game_State_Name.in_lobby)
        end
    end
    self.curr_room_key = room_key
    if not self._app.panel_mgr:is_panel_enable(UI_Panel_Name.room_panel) then
        self._app.panel_mgr:open_panel(UI_Panel_Name.room_panel)
    end
end

function FightLogic:_on_event_room_over(room_key)
    if self.curr_room_key == room_key then
        if self._app.state_mgr:in_state(App_State_Name.in_game, In_Game_State_Name.fight) then
            self._app.state_mgr:change_in_game_state(In_Game_State_Name.in_lobby)
        end
    end
end

function FightLogic:_on_event_room_change(room_key)
    if self.curr_room_key ~= room_key then
        return
    end
    if Room_State.in_fight == self._room_data.remote_room_state then
        self._app.ui_mgr.msg_box:add_msg_box()
    end
end







