
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
    ---@type Bind_Fight_State
    self.bind_fight_state = Bind_Fight_State.idle
    self.accept_fight_key = nil
end

function FightData:_on_init()
    FightData.super._on_init(self)

    self._room_data = self._app.data_mgr.room

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_bind_fight, Functional.make_closure(self._on_msg_rsp_bind_fight, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_fight_state_two_dice, Functional.make_closure(self._on_msg_sync_fight_state_two_dice, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_fight_opera, Functional.make_closure(self._on_msg_rsp_fight_opera, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.fight_connect_done, Functional.make_closure(self._on_event_fight_net_connect_done, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.fight_connect_ready_change, Functional.make_closure(self._on_event_fight_connect_ready_change, self))

    self._event_binder:bind(self._app.data_mgr.room, Room_Data_Event.room_state_change, Functional.make_closure(self._on_event_room_state_change, self))
end

function FightData:_on_release()
    FightData.super._on_release(self)
end

function FightData:bind_fight()
    self._fight_net:set_host(self.server_ip, self.server_port)
    self._fight_net:connect()
    self:_set_bind_fight_state(Bind_Fight_State.binding)
end

function FightData:unbind_fight()
    self._fight_net:disconnect()
    self.accept_fight_key = nil
    self.fight_key = nil
    self.bind_fight_state = Bind_Fight_State.idle
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
        self:_set_bind_fight_state(Bind_Fight_State.connect_fail)
    end
end

function FightData:_on_event_fight_connect_ready_change(is_ready)
    if not is_ready then
        if Bind_Fight_State.ready == self.bind_fight_state then
            self:_set_bind_fight_state(Bind_Fight_State.net_error)
        end
    end
end

function FightData:_on_event_room_state_change(room_key)
    self:try_extract_fight_data()
end

function FightData:try_extract_fight_data()
    if self.accept_fight_key
            and self._room_data.fight_data.fight_key == self.accept_fight_key
            and Room_State.in_fight == self._room_data.remote_room_state then
        self.server_ip = self._room_data.fight_data.ip
        self.server_port = self._room_data.fight_data.port
        self.fight_token = self._room_data.fight_data.token
        self.fight_key = self._room_data.fight_data.fight_key
        self.room_key = self._room_data.room_key
    end
end

---@param val Bind_Fight_State
function FightData:_set_bind_fight_state(val)
    self.bind_fight_state = val
    self:fire(Fight_Data_Event.bind_fight_state_chanage, self.bind_fight_state, self.fight_key)
end

function FightData:set_accept_fight_key(fight_key)
    self.accept_fight_key = fight_key
    self:try_extract_fight_data()
end


