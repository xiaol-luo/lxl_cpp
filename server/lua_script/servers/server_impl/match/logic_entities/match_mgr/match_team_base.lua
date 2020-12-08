

---@class MatchTeamBase
---@field match_key string
---@field extra_params table<string, string>
---@field teammate_role_ids table<number, number>
---@field match_logic MatchLogicBase
MatchTeamBase = MatchTeamBase or class("MatchTeamBase")

function MatchTeamBase:ctor(match_logic, match_key, ask_role_id, teammate_role_ids, extra_params)
    self.match_logic = match_logic
    self.ask_role_id = ask_role_id
    self.match_key = match_key
    self.teammate_role_ids = teammate_role_ids
    self.extra_params = extra_params
end


