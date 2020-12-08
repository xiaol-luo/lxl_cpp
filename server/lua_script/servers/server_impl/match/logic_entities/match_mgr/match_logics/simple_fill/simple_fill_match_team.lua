
---@class SimpleFillMatchTeam:MatchTeamBase
SimpleFillMatchTeam = SimpleFillMatchTeam or class("SimpleFillMatchTeam", MatchTeamBase)

function SimpleFillMatchTeam:ctor(match_logic, match_key, teammate_role_ids, extra_params)
    SimpleFillMatchTeam.super.ctor(self, match_logic, match_key, teammate_role_ids, extra_params)
end