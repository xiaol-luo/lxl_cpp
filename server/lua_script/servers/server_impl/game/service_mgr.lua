
---@class ServiceMgr: ServiceMgrBase
ServiceMgr = class("ServiceMgr", ServiceMgrBase)

function ServiceMgr:ctor(server)
    ServiceMgr.super.ctor(self, server)
end

function ServiceMgr:_on_init()
    local world_online_shadown = OnlineWorldShadow:new(self, Service_Name.world_online_shadow)
    world_online_shadown:init()
    self:add_service(world_online_shadown)

    return true
end
