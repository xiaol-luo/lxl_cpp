
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
---@field room_camps table<number, RoomCampBase>
---@field state Room_State
---@field id_to_role table<number, RoomRoleBase>
RoomBase = RoomBase or class("RoomBase")

function RoomBase:ctor()
    self.state = Room_State.setup
    self.room_key = nil
    self.room_camps = {}
    self.id_to_role = {}
end

---@field room RoomBase
function RoomBase.gen_base_room(room, room_key, setup_data)
    room.room_key = room_key
    room.match_theme = setup_data.match_theme
    for k, camp in pairs(setup_data.room_camps) do
        local room_camp = RoomCampBase:new()
        room.room_camps[k] = room_camp
        for _, role_id in ipairs(camp.role_ids) do
            local room_role = RoomRoleBase:new()
            room_role.role_id = role_id
            room_camp.id_to_role[role_id] = room_role
            room.id_to_role[role_id] = room_role
        end
    end
end

---@class room RoomBase
function RoomBase:collect_sync_room_state()
    local ret = {}
    ret.room_key = self.room_key
    ret.state = self.state
    ret.room_camps = {}
    for camp_k, camp_v in pairs(self.room_camps) do
        local camp = {}
        ret.room_camps[camp_k] = camp
        for role_id, _ in pairs(camp_v.id_to_role) do
            local role_data = {}
            camp[role_id] = role_data
            role_data.role_id = role_id
        end
    end
    return ret
end



