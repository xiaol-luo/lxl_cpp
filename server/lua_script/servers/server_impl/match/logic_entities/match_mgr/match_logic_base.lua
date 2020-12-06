
---@class MatchLogicBase
MatchLogicBase = MatchLogicBase or class("MatchLogicBase")

function MatchLogicBase:ctor(match_mgr, logic_setting)
    ---@type MatchMgr
    self._match_mgr = match_mgr
    ---@type table
    self._logic_setting = logic_setting
end

function MatchLogicBase:init()
    self._on_init()
end

function MatchLogicBase:start()
    self._on_start()
end

function MatchLogicBase:stop()
    self._on_stop()
end

function MatchLogicBase:release()
    self._on_release()
end

function MatchLogicBase:update()
    self._on_update()
end

function MatchLogicBase:create_match_team(match_key, ask_role_id, teammate_role_ids, extra_param)
    -- override by subclass
    return Error_Unknown, nil
end

function LogicEntityBase:_on_init(...)
    -- override by subclass
end

function LogicEntityBase:_on_start()
    -- override by subclass
end

function LogicEntityBase:_on_stop()
    -- override by subclass
end

function LogicEntityBase:_on_release()
    -- override by subclass
end

function LogicEntityBase:_on_update()
    -- override by subclass
end


