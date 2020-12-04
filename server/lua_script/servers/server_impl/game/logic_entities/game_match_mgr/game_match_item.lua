
---@class GameMatchItem
---@field role_id number
---@field state Game_Match_Item_State
---@field match_server_key string
---@field match_key string
---@field match_theme string
---@field leader_role_id number
---@field teammate_role_ids table<number, number>
GameMatchItem = GameMatchItem or class("GameMatchItem")

function GameMatchItem:ctor()
    self.role_id = 0
    self.state = 0
    self.match_server_key = nil
    self.match_key = nil
    self.match_theme = nil
    self.leader_role_id = 0
    self.teammate_role_ids = {}
end



