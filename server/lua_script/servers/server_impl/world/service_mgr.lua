
---@class ServiceMgr: ServiceMgrBase
ServiceMgr = class("ServiceMgr", ServiceMgrBase)

function ServiceMgr:ctor(server)
    ServiceMgr.super.ctor(self, server)
end

function ServiceMgr:_on_init()
    local hotfix_svc = HotfixService:new(self, Service_Name.hotfix)
    hotfix_svc:init("hotifx_dir")
    self:add_service(hotfix_svc)

    local discovery = DiscoveryService:new(self, Service_Name.discovery)
    discovery:init()
    self:add_service(discovery)

    local peer_net_svc = PeerNetService:new(self, Service_Name.peer_net)
    peer_net_svc:init("hotifx_dir")
    self:add_service(peer_net_svc)

    return true
end
