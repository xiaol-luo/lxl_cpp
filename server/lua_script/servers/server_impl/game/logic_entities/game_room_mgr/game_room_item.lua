
---@class GameRoomItem
---@field role_id number
---@field state Game_Match_Item_State
---@field match_server_key string
---@field match_key string
---@field match_theme string
---@field leader_role_id number
---@field teammate_role_ids table<number, number>
GameRoomItem = GameRoomItem or class("GameRoomItem")

function GameRoomItem:ctor()
    self.role_id = 0
    self.state = Game_Room_Item_State.idle
    self.match_server_key = nil
    self.match_key = nil
    self.match_theme = nil
    self.leader_role_id = 0
    self.teammate_role_ids = {}
end

