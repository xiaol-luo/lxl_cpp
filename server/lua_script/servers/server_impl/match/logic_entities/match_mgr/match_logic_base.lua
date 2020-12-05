
---@class MatchLogicBase
MatchLogicBase = MatchLogicBase or class("MatchLogicBase")

function MatchLogicBase:ctor(match_mgr, logic_setting)
    ---@type MatchMgr
    self._match_mgr = match_mgr
    ---@type table
    self._logic_setting = logic_setting
end

function MatchLogicBase:init()

end

function MatchLogicBase:start()

end

function MatchLogicBase:stop()

end

function MatchLogicBase:release()

end

function MatchLogicBase:create_match_team(ask_role_id, teammate_role_ids, extra_param)
    -- override by subclass
    return nil
end



