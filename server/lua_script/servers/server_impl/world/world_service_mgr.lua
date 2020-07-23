
---@class WorldServiceMgr: ServiceMgrBase
WorldServiceMgr = class("WorldServiceMgr", ServiceMgrBase)

function WorldServiceMgr:ctor(server)
    WorldServiceMgr.super.ctor(self, server)
end

function WorldServiceMgr:_on_init()
    do
        local svc = OnlineWorldShadow:new(self, Service_Name.online_world_shadow)
        svc:init()
        self:add_service(svc)
    end

    do
        local svc = WorldLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
