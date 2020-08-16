
---@class PlatformLogicService:LogicServiceBase
---@field platform_logic PlatformLogic
PlatformLogicService = PlatformLogicService or class("LogicService", LogicServiceBase)

function PlatformLogicService:_on_init()
    PlatformLogicService.super._on_init(self)

    do
        local logic = PlatformLogic:new(self, Platform_Logic_Name.platform_logic)
        logic:init()
        self:add_logic(logic)
    end
end