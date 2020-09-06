
---@class ExampleLogicService:LogicServiceBase
---@field example_mgr ExampleMgr
ExampleLogicService = ExampleLogicService or class("LogicService", LogicServiceBase)

function ExampleLogicService:_on_init()
    ExampleLogicService.super._on_init(self)

    do
        local logic = ExampleMgr:new(self, Example_Logic_Name.example_mgr)
        logic:init()
        self:add_logic(logic)
    end

end