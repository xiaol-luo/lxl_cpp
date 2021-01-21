
---@class SimpleFillMatchLogic:MatchLogicBase
SimpleFillMatchLogic = SimpleFillMatchLogic or class("SimpleFillMatchLogic", MatchLogicBase)

function SimpleFillMatchLogic:ctor(match_mgr, match_theme, logic_setting)
    SimpleFillMatchLogic.super.ctor(self, match_mgr, match_theme, logic_setting)
    self._last_do_match_timestamp = 0
    self._Game_Min_Role_Num = 1
end

function SimpleFillMatchLogic:create_match_team(match_key, ask_role_id, teammate_role_ids, extra_param)
    local ret = SimpleFillMatchTeam:new(self, match_key, ask_role_id, teammate_role_ids, extra_param)
    return ret
end


function SimpleFillMatchLogic:_on_update()
    local now_sec = logic_sec()
    if now_sec - self._last_do_match_timestamp >= 2 then
        self._last_do_match_timestamp = now_sec

        local pre_key = nil
        local consume_match_teams = {}
        repeat
            local hit_team_keys = {}
            local hit_teams = {}
            local hit_team_role_num = 0
            ---@type MatchTeamBase
            local hit_team = nil
            repeat
                pre_key, hit_team = next(self._key_to_team, pre_key)
                if not pre_key then
                    break
                end
                table.insert(hit_team_keys, pre_key)
                hit_team_role_num = hit_team_role_num + #hit_team.teammate_role_ids
                table.insert(hit_teams, hit_team)
                if hit_team_role_num >= self._Game_Min_Role_Num then -- 只要人数满足self._Game_Min_Role_Num，就打包成队
                    break
                end
            until false

            if hit_team_role_num >= self._Game_Min_Role_Num then
                local match_game = MatchGameBase:new()
                table.insert(self._ready_match_games, match_game)
                match_game.match_theme = self._match_theme
                match_game.unique_key = gen_uuid()
                local match_camp = MatchCampBase:new()
                table.insert(match_game.match_camps, match_camp)
                for _, team in ipairs(hit_teams) do
                    match_camp.match_teams[team.match_key] = team
                end
                table.append(consume_match_teams, hit_team_keys)
            end

            if not pre_key then
                break
            end

        until false
        for _, match_key in pairs(consume_match_teams) do
            self:leave_match(match_key)
        end
    end
end

function SimpleFillMatchLogic:_check_can_enter_match(match_team)
    return true
end

function SimpleFillMatchLogic:_on_enter_match(match_team)

end

function SimpleFillMatchLogic:_on_leave_match(match_team)

end