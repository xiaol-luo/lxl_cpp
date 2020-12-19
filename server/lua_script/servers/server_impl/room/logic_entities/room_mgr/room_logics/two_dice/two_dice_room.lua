
---@class TwoDiceRoom: RoomBase
---@field role_replys table<number, Reply_State>
---@field try_apply_fight_sec number
---@field try_apply_fight_times number
TwoDiceRoom = TwoDiceRoom or class("TwoDiceRoom", RoomBase)

function TwoDiceRoom:ctor(room_key, setup_data)
    TwoDiceRoom.super.ctor(self)
    RoomBase.gen_base_room(self, room_key, setup_data)
    self.role_replys = {}
    self.try_apply_fight_sec = nil
    self.try_apply_fight_times = 0
end
