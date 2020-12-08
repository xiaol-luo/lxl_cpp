
---@class MatchLogicBase
MatchLogicBase = MatchLogicBase or class("MatchLogicBase")

function MatchLogicBase:ctor(match_mgr, logic_setting)
    ---@type MatchMgr
    self._match_mgr = match_mgr
    ---@type table
    self._logic_setting = logic_setting
    ---@type table<string, MatchTeamBase>
    self._key_to_team = {}
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

function MatchLogicBase:_on_init(...)
    -- override by subclass
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


