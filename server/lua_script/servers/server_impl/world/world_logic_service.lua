
---@class WorldLogicService:LogicServiceBase
WorldLogicService = WorldLogicService or class("LogicService", LogicServiceBase)

function WorldLogicService:_on_init()
    WorldLogicService.super._on_init(self)

    do
        local logic = RoleStateMgr:new(self, World_Logic_Name.role_state_mgr)
        logic:init()
        self:add_logic(logic)
    end

end