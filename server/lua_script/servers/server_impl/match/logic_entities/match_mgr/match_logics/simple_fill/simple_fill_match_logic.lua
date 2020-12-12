
---@class SimpleFillMatchLogic:MatchLogicBase
SimpleFillMatchLogic = SimpleFillMatchLogic or class("SimpleFillMatchLogic", MatchLogicBase)

function SimpleFillMatchLogic:ctor(match_mgr, logic_setting)
    SimpleFillMatchLogic.super.ctor(self, match_mgr, logic_setting)
    self._last_do_match_timestamp = 0
end

function SimpleFillMatchLogic:create_match_team(match_key, ask_role_id, teammate_role_ids, extra_param)
    local ret = SimpleFillMatchTeam:new(self, match_key, ask_role_id, teammate_role_ids, extra_param)
    return ret
end


function SimpleFillMatchLogic:_on_update()
    local now_sec = logic_sec()
    if now_sec - self._last_do_match_timestamp >= 1 then
        self._last_do_match_timestamp = now_sec

        local consume_match_teams = {}
        local pre_key = nil
        repeat
            --[[
            local key_1, match_team_1 = next(self._key_to_team, pre_key)
            if not key_1 then
                break
            end
            --]]
            local key_2, match_team_2 = next(self._key_to_team, pre_key)
            if not key_2 then
                break
            end
            pre_key = key_2
            -- table.insert(consume_match_teams, key_1)
            table.insert(consume_match_teams, key_2)
            local match_game = MatchGameBase:new()
            match_game.unique_key = gen_uuid()
            table.insert(self._ready_match_games, match_game)
            do
                local team = match_team_2
                local match_camp = MatchCampBase:new()
                match_camp.match_teams[team.match_key] = team
                table.insert(match_game.match_camps, match_camp)
            end
        until false
        for _, match_key in pairs(consume_match_teams) do
            -- self._key_to_team[match_key] = nil
            self:leave_match(match_key)
        end
    end
end

function SimpleFillMatchLogic:__check_can_enter_match(match_team)
    return true
end

function SimpleFillMatchLogic:_on_enter_match(match_team)

end

function SimpleFillMatchLogic:_on_leave_match(match_team)

end