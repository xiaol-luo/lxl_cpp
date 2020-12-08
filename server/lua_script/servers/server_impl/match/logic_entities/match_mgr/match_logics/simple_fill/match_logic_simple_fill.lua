
---@class MatchLogicSimpleFill:MatchLogicBase
MatchLogicSimpleFill = MatchLogicSimpleFill or class("MatchLogicSimpleFill", MatchLogicBase)

function MatchLogicSimpleFill:ctor(match_mgr, logic_setting)
    MatchLogicSimpleFill.super.ctor(self, match_mgr, logic_setting)
end

function MatchLogicSimpleFill:create_match_team(match_key, ask_role_id, teammate_role_ids, extra_param)
    return Error_None, {}
end