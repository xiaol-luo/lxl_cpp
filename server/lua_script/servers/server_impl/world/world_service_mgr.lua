
---@class WorldServiceMgr: ServiceMgrBase
WorldServiceMgr = class("WorldServiceMgr", ServiceMgrBase)

function WorldServiceMgr:ctor(server)
    WorldServiceMgr.super.ctor(self, server)
end

function WorldServiceMgr:_on_init()
    do
        local svc = ServerRoleShadow:new(self, Service_Name.work_world_shadow, self.server:get_zone_name(), Server_Role.World)
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
