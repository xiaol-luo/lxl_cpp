
---@class ServiceMgr: ServiceMgrBase
ServiceMgr = class("ServiceMgr", ServiceMgrBase)

function ServiceMgr:ctor(server)
    ServiceMgr.super.ctor(self, server)
end

function ServiceMgr:_on_init()

    --local world_online_shadown = OnlineWorldShadow:new(self, Service_Name.online_world_shadow)
    --world_online_shadown:init()
    --self:add_service(world_online_shadown)

    local world_online_monitor = OnlineWorldMonitor:new(self, Service_Name.online_world_monitor)
    world_online_monitor:init()
    self:add_service(world_online_monitor)

    return true
end
