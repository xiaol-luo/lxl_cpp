
---@class RoomData:DataBase
RoomData = RoomData or class("RoomData", DataBase)

assert(DataBase)

function RoomData:ctor(data_mgr)
    RoomData.super.ctor(self, data_mgr, "room")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net
end

function RoomData:_on_init()
    Fight.super._on_init(self)

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_room_state, Functional.make_closure(self._on_msg_sync_room_state, self))
end

function RoomData:_on_release()
    Fight.super._on_release(self)
end

function MatchData:pull_room_state()
    self._gate_net:send_msg(Fight_Pid.pull_room_state)
end

function RoomData:_on_msg_sync_room_state(pid, msg)
    log_print("RoomData:_on_msg_sync_room_state(pid, msg)", pid, msg)

    if msg.remote_room_state == Room_State.in_fight then
        self._fight_net:set_host(msg.fight_server_ip, msg.fight_server_port)
        self._fight_net:connect()
    end
    self.fight_data = msg
end



