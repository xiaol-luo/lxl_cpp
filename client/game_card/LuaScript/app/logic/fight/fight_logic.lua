
---@class FightLogic:LogicBase
FightLogic = FightLogic or class("FightLogic", LogicBase)

function FightLogic:ctor(logic_mgr)
    FightLogic.super.ctor(self, logic_mgr, "fight")
    ---@type RoomData
    self._room_data = nil
end

function FightLogic:_on_init()
    self._room_data = self._app.data_mgr.room
    self._event_binder:bind(self._room_data, Room_Data_Event.ask_enter_room,
            Functional.make_closure(self._on_event_ask_enter_room, self))
end

function FightLogic:_on_event_ask_enter_room(ev_data)
    local room_key = ev_data.room_key
    local match_server_key = ev_data.match_server_key


    ---@type UIMessageData
    local msg_data = UIMessageData:new()
    msg_data.str_content = "进入新的房间"
    msg_data.cancel_cb = Functional.make_closure(self._on_cb_choose_enter_room, self, ev_data, false)
    msg_data.confirm_cb = Functional.make_closure(self._on_cb_choose_enter_room, self, ev_data, true)
    self._app.ui_mgr.msg_box:add_msg_box(msg_data)
end

function FightLogic:_on_cb_choose_enter_room(ev_data, is_accept)
    self._app.net_mgr.game_gate_net:send_msg(Fight_Pid.rpl_svr_accept_enter_room, {
        room_key = ev_data.room_key,
        match_server_key = ev_data.match_server_key,
        is_accept = is_accept,
    })
    self._room_data:_handle_room_state_pto(nil)
end




