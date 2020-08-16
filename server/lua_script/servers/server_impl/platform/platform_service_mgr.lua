
---@class PlatformServiceMgr: ServiceMgrBase
---@field logics PlatformLogicService
---@field server PlatformServer
PlatformServiceMgr = class("PlatformServiceMgr", ServiceMgrBase)

function PlatformServiceMgr:ctor(server)
    PlatformServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_http_service)
end

function PlatformServiceMgr:_on_init()
    do
        local svc = PlatformLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
