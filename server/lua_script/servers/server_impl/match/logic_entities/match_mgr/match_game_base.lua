
---@class MatchGameBase
---@field unique_key string
---@field match_theme string
---@field match_camps table<number, MatchCampBase>
MatchGameBase = MatchGameBase or class("MatchGameBase")

function MatchGameBase:ctor()
    self.unique_key = nil
    self.match_theme = nil
    self.match_camps = {}
end
