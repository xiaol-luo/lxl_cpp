
---@class TwoDiceRoom: RoomBase
---@field role_replys table<number, Reply_State>
TwoDiceRoom = TwoDiceRoom or class("TwoDiceRoom", RoomBase)

function TwoDiceRoom:ctor(room_key, setup_data)
    TwoDiceRoom.super.ctor(self)
    RoomBase.gen_base_room(self, room_key, setup_data)
    self.role_replys = {}
    self.try_apply_fight_timestamp = nil
    self.fight_server_key = nil
end
