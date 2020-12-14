
---@class TwoDiceRoom: RoomBase
TwoDiceRoom = TwoDiceRoom or class("TwoDiceRoom", RoomBase)

function TwoDiceRoom:ctor(room_key, setup_data)
    TwoDiceRoom.super.ctor(self)
    RoomBase.gen_base_room(self, room_key, setup_data)
end
