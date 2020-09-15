
---@class MatchLogicService:LogicServiceBase
---@field match_mgr MatchMgr
MatchLogicService = MatchLogicService or class("LogicService", LogicServiceBase)

function MatchLogicService:_on_init()
    MatchLogicService.super._on_init(self)

    do
        local logic = MatchMgr:new(self, Match_Logic_Name.match_mgr)
        logic:init()
        self:add_logic(logic)
    end

    do
        local logic = MatchRoleMgr:new(self, Match_Logic_Name.match_role_mgr)
        logic:init()
        self:add_logic(logic)
    end

end