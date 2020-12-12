
---@class MatchCampBase
---@field match_teams table<string, MatchTeamBase>
---@field match_key string
MatchCampBase = MatchCampBase or class("MatchGameBase")

function MatchCampBase:ctor()
    self.match_teams = {}
end
