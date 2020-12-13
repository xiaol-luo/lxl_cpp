
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

function MatchGameBase:collect_setup_room_data()
    local ret = {}
    ret.match_theme = self.match_theme
    ret.room_camps = {}
    for _, match_camp in pairs(self.match_camps) do
        local room_camp = {}
        table.insert(ret.room_camps, room_camp)
        for _, match_team in pairs(match_camp.match_teams) do
            table.append(room_camp, match_team.teammate_role_ids)
        end
    end
    return ret
end