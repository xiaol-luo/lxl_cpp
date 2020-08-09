
---@class ServiceMgr: ServiceMgrBase
ServiceMgr = class("ServiceMgr", ServiceMgrBase)

function ServiceMgr:ctor(server)
    ServiceMgr.super.ctor(self, server)
end

function ServiceMgr:_on_init()
    do
        local world_online_monitor = OnlineWorldMonitor:new(self, Service_Name.online_world_monitor)
        world_online_monitor:init()
        self:add_service(world_online_monitor)
    end

    do
        local svc = ServerRoleMonitor:new(self, Service_Name.world_server_monitor,
                self.server:get_zone_name(), Server_Role.World, {Server_Role.World, Server_Role.Gate, Server_Role.Game})
        svc:init()
        self:add_service(svc)
    end

    return true
end
