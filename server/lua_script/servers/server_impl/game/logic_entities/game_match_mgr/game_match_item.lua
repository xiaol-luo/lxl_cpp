
---@class GameMatchItem
---@field uid number
---@field role_match GameRoleMatch
---@field match_server_key string
---@field match_key string
GameMatchItem = GameMatchItem or class("GameMatchItem")

function GameMatchItem:ctor()
    self.uid = 0
    -- self.role_match = nil
    self.match_server_key = nil
    self.match_key = nil
    self.leader_uids = 0
    self.teammate_uids = {}
end

