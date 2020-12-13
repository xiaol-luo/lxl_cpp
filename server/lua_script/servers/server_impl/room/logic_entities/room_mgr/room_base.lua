

---@class RoomBase
---@field room_key string
---@field match_theme string
---@field room_camps table<number, RoomCampBase>
RoomBase = RoomBase or class("RoomBase")

function RoomBase:ctor()
    self.room_key = nil
    self.match_theme = nil
    self.room_camps = {}
end