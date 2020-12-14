
---@class Room_State
Room_State = {}
Room_State.setup = "setup"
Room_State.ask_enter_room = "ask_enter_room"
Room_State.wait_apply_fight = "wait_start_fight"
Room_State.apply_fight = "apply_fight"
Room_State.wait_fight_over = "wait_fight_over"
Room_State.all_over = "all_over"

---@class RoomBase
---@field room_key string
---@field match_theme string
---@field camp_roles table<number, RoomCampBase>
---@field state Room_State
RoomBase = RoomBase or class("RoomBase")

function RoomBase:ctor()
    self.state = Room_State.setup
    self.room_key = nil
    self.camp_roles = {}
end

---@field room RoomBase
function RoomBase.gen_base_room(room, room_key, setup_data)
    room.room_key = room_key
    room.match_theme = setup_data.match_theme
    for k, role_ids in pairs(setup_data.camp_roles) do
        local room_camp = RoomCampBase:new()
        room.camp_roles[k] = room_camp
        for _, role_id in ipairs(role_ids) do
            local room_role = RoomRoleBase:new()
            room_role.role_id = role_id
            room_camp.id_to_role[role_id] = room_role
        end
    end
end



