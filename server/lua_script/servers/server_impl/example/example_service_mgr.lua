
---@class ExampleServiceMgr: ServiceMgrBase
---@field logics ExampleLogicService
ExampleServiceMgr = class("ExampleServiceMgr", ServiceMgrBase)

function ExampleServiceMgr:ctor(server)
    ExampleServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_game_service)
end

function ExampleServiceMgr:_on_init()
    do
        local svc = ExampleLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
