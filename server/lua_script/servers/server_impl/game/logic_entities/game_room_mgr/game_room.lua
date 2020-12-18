
---@class GameRoom
---@field role_id number
---@field state Game_Match_Item_State
---@field match_server_key string
---@field room_key string
---@field match_theme string
---@field leader_role_id number
---@field teammate_role_ids table<number, number>
GameRoom = GameRoom or class("GameRoom")

function GameRoom:ctor()
    self.role_id = 0
    self.state = Game_Room_Item_State.idle
    self.room_server_key = nil
    self.room_key = nil

    self.remote_room = {}
    self.remote_room.state = Room_State.idle
    self.remote_room.match_theme = nil
    self.remote_room.fight_key = nil
    self.remote_room.fight_server_key = nil
    self.remote_room.fight = nil
    self.remote_room.raw_msg = nil
end

