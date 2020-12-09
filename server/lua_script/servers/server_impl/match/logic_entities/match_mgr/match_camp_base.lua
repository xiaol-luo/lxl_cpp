
---@class MatchCampBase
---@field match_teams table<string, MatchTeamBase>
MatchCampBase = MatchCampBase or class("MatchGameBase")

function MatchCampBase:ctor()
    self.match_teams = {}
end
