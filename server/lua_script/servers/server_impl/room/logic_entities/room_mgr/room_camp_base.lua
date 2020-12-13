

---@class RoomCampBase
---@field id_to_role table<number, RoomRoleBase>
RoomCampBase = RoomCampBase or class("RoomCampBase")

function RoomCampBase:ctor()
    self.id_to_role = {}
end


