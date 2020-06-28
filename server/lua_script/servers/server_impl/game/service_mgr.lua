
---@class ServiceMgr: ServiceMgrBase
ServiceMgr = class("ServiceMgr", ServiceMgrBase)

function ServiceMgr:ctor(server)
    ServiceMgr.super.ctor(self, server)
end

function ServiceMgr:_on_init()
    local online_world_shadown = OnlineWorldShadow:new(self, Service_Name.online_world_shadow)
    online_world_shadown:init()
    self:add_service(online_world_shadown)

    return true
end
