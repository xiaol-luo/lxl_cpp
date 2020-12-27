
---@class RoomData:DataBase
RoomData = RoomData or class("RoomData", DataBase)

assert(DataBase)

function RoomData:ctor(data_mgr)
    RoomData.super.ctor(self, data_mgr, "room")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net

    self.room_key = ""
    self.state = Game_Room_Item_State.idle
    self.match_theme = ""
    self.remote_room_state = Room_State.idle
    self.fight_data = {}
    self.fight_data.fight_key = ""
    self.fight_data.ip = nil
    self.fight_data.port = 0
    self.fight_data.token = ""
end

function RoomData:_on_init()
    RoomData.super._on_init(self)

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_room_state, Functional.make_closure(self._on_msg_sync_room_state, self))
end

function RoomData:_on_release()
    Fight.super._on_release(self)
end

function RoomData:pull_room_state()
    self._gate_net:send_msg(Fight_Pid.pull_room_state)
end

function RoomData:_on_msg_sync_room_state(pid, msg)
    log_print("RoomData:_on_msg_sync_room_state(pid, msg)", pid, msg)

    if msg.remote_room_state == Room_State.in_fight then
        -- self._fight_net:set_host(msg.fight_server_ip, msg.fight_server_port)
        -- self._fight_net:connect()
    end
    self:_handle_room_state_pto(msg)
end

function RoomData:_handle_room_state_pto(msg)
    local old_key = self.room_key
    local old_state = self.state
    if nil == msg then
        self.room_key = ""
        self.state = Game_Room_Item_State.idle
        self.match_theme = ""
        self.remote_room_state = Room_State.idle
        self.fight_data.fight_key = ""
        self.fight_data.ip = nil
        self.fight_data.port = 0
        self.fight_data.token = ""
    else
        self.room_key = msg.room_key
        self.state = msg.state
        self.match_theme = msg.match_theme
        self.remote_room_state = msg.remote_room_state
        self.fight_data.fight_key = msg.fight_key
        self.fight_data.ip = msg.fight_server_ip
        self.fight_data.port = msg.fight_server_port
        self.fight_data.token = msg.fight_token
    end
    if old_key ~= self.room_key then
        if #old_key > 0 then
            if Game_Room_Item_State.all_over ~= old_state then
                self:fire(Room_Data_Event.room_over, old_key)
            end
        end
        if #self.room_key > 0 then
            self:fire(Room_Data_Event.room_start, self.room_key)
            self:fire(Room_Data_Event.room_state_change)
        end
    else
        if #self.match_theme then
            if old_state ~= self.state and Game_Room_Item_State.all_over == self.state then
                self:fire(Room_Data_Event.room_over, self.room_key)
            end
            self:fire(Room_Data_Event.room_state_change)
        end
    end
end



