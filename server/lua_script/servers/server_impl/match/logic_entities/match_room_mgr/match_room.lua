
---@class MatchRoom
---@field room_key string
---@field state Match_Room_State
---@field room_server_key string
---@field match_game MatchGameBase
---@field timeout_timestamp number
---@field role_replys table<number, Reply_State>
MatchRoom = MatchRoom or class("MatchRoom")

function MatchRoom:ctor()
    self.room_key = nil
    self.room_server_key = nil
    self.match_game = nil
    self.timeout_timestamp = 0
    self.role_replys = {}
end

