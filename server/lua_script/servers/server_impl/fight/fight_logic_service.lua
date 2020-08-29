
---@class FightLogicService:LogicServiceBase
---@field fight_mgr FightMgr
FightLogicService = FightLogicService or class("LogicService", LogicServiceBase)

function FightLogicService:_on_init()
    FightLogicService.super._on_init(self)

    do
        local logic = FightMgr:new(self, Fight_Logic_Name.fight_mgr)
        logic:init()
        self:add_logic(logic)
    end

end