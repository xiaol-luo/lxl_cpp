
---@class FightData:DataBase
FightData = FightData or class("Fight", DataBase)

assert(DataBase)

function FightData:ctor(data_mgr)
    FightData.super.ctor(self, data_mgr, "fight")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net
    ---@type FightNetBase
    self._fight_net = self._app.net_mgr.fight_net
    ---@type RoomData
    self._room_data = nil

    self.server_ip = nil
    self.server_port = 0
    self.fight_key = ""
    self.token = ""
    self.room_key = ""
    self._is_bind_fight = false

    self.fight_state = {}
end

function FightData:_on_init()
    FightData.super._on_init(self)

    self._room_data = self._app.data_mgr.room

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_bind_fight, Functional.make_closure(self._on_msg_rsp_bind_fight, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_fight_state_two_dice, Functional.make_closure(self._on_msg_sync_fight_state_two_dice, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_fight_opera, Functional.make_closure(self._on_msg_rsp_fight_opera, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.fight_connect_done, Functional.make_closure(self._on_event_fight_net_connect_done, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.fight_connect_ready_change, Functional.make_closure(self._on_event_fight_connect_ready_change, self))

    self._event_binder:bind(self._app.data_mgr.room, Room_Data_Event.room_start, Functional.make_closure(self._on_event_room_start, self))
    self._event_binder:bind(self._app.data_mgr.room, Room_Data_Event.room_state_change, Functional.make_closure(self._on_event_room_state_change, self))
    self._event_binder:bind(self._app.data_mgr.room, Room_Data_Event.room_over, Functional.make_closure(self._on_event_room_over, self))
end

function FightData:_on_release()
    FightData.super._on_release(self)
end

function FightData:req_bind_fight()
    self._fight_net:set_host(self.server_ip, self.server_port)
    self._fight_net:connect()
    --[[

    --]]
end

function FightData:pull_fight_state()
    self._gate_net:send_msg(Fight_Pid.pull_fight_state, {

    })
end

function FightData:req_fight_opera()
    self._gate_net:send_msg(Fight_Pid.req_fight_opera, {

    })
end

function FightData:_on_msg_rsp_bind_fight(pid, msg)
    log_print("FightData:_on_msg_rsp_bind_fight(pid, msg)", pid, msg)
end

function FightData:_on_msg_sync_fight_state_two_dice(pid, msg)
    log_print("FightData:_on_msg_sync_fight_state_two_dice(pid, msg)", pid, msg)

end

function FightData:_on_msg_rsp_fight_opera(pid, msg)
    log_print("FightData:_on_msg_rsp_fight_opera(pid, msg)", pid, msg)
end

function FightData:_on_event_fight_net_connect_done(is_ready, error_msg)
    log_print("FightData:_on_fight_net_connect_done", is_ready, error_msg)
    if is_ready then
        self._fight_net:send_msg(Fight_Pid.req_bind_fight, {
            fight_key = self.fight_key,
            token = self.fight_token,
            role_id = self._data_mgr.main_role:get_role_id(),
        })
    else
        self:fire(Fight_Data_Event.bind_fight_done, false)
    end
end

function FightData:_on_event_fight_connect_ready_change(is_ready)

end

function FightData:_on_event_room_start(room_key)

end

function FightData:_on_event_room_state_change()
    if Room_State.in_fight == self._room_data.remote_room_state then
        self.server_ip = self._room_data.fight_data.ip
        self.server_port = self._room_data.fight_data.port
        self.fight_token = self._room_data.fight_data.token
        self.fight_key = self._room_data.fight_data.fight_key
        self.room_key = self._room_data.room_key
    end
end

function FightData:_on_event_room_over(room_key)

end


