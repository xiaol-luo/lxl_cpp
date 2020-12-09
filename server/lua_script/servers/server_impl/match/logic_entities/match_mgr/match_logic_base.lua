
---@class MatchLogicBase
MatchLogicBase = MatchLogicBase or class("MatchLogicBase")

function MatchLogicBase:ctor(match_mgr, logic_setting)
    ---@type MatchMgr
    self._match_mgr = match_mgr
    ---@type table
    self._logic_setting = logic_setting
    ---@type table<string, MatchTeamBase>
    self._key_to_team = {}
    ---@type table<number, MatchGameBase>
    self._ready_match_games = {}
end

function MatchLogicBase:get_team(match_key)
    return self._key_to_team[match_key]
end

function MatchLogicBase:init()
    self:_on_init()
end

function MatchLogicBase:start()
    self:_on_start()
end

function MatchLogicBase:stop()
    self:_on_stop()
end

function MatchLogicBase:release()
    self:_on_release()
end

function MatchLogicBase:update()
    self:_on_update()
end

function MatchLogicBase:create_match_team(match_key, ask_role_id, teammate_role_ids, extra_param)
    -- override by subclass
    return nil
end

---@param match_team MatchTeamBase
function MatchLogicBase:enter_match(match_team)
    if not match_team or not match_team.match_key then
        return false
    end
    if self:get_team(match_team.match_key) then
        return false
    end

    if not self:__check_can_enter_match(match_team) then
        return false
    end

    self._key_to_team[match_team.match_key] = match_team
    self:_on_enter_match(match_team)
    return true
end

function MatchLogicBase:leave_match(match_key)
    -- override by subclass
    local match_team = self:get_team(match_key)
    if match_team then
        self._key_to_team[match_key] = nil
        self:_on_leave_match(match_team)
    end
end

function MatchLogicBase:pop_ready_match_games()
    if not next(self._ready_match_games) then
        return nil
    end
    local ret = self._ready_match_games
    self._ready_match_games = {}
    return ret
end

function MatchLogicBase:_on_init(...)

end

function MatchLogicBase:_on_start()
    -- override by subclass
end

function MatchLogicBase:_on_stop()
    -- override by subclass
end

function MatchLogicBase:_on_release()
    -- override by subclass
end

function MatchLogicBase:_on_update()
    -- override by subclass
end

function MatchLogicBase:__check_can_enter_match(match_team)
    -- override by subclass
    return false
end

function MatchLogicBase:_on_enter_match(match_team)
    -- override by subclass
end

function MatchLogicBase:_on_leave_match(match_team)
    -- override by subclass
end


