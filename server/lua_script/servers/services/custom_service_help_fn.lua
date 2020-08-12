
---@class CustomServiceHelpFn
CustomServiceHelpFn = CustomServiceHelpFn or {}

function CustomServiceHelpFn.setup_game_service(self)
    do
        local svc = HotfixService:new(self, Service_Name.hotfix)
        svc:init("hotfix_dir")
        self:add_service(svc)
    end
    do
        local svc = ZoneSettingService:new(self, Service_Name.zone_setting)
        svc:init()
        self:add_service(svc)
    end
    do
        local svc = JoinClusterService:new(self, Service_Name.join_cluster)
        svc:init()
        self:add_service(svc)
    end
    do
        local svc = DiscoveryService:new(self, Service_Name.discovery)
        svc:init()
        self:add_service(svc)
    end
    do
        local svc = PeerNetService:new(self, Service_Name.peer_net)
        svc:init()
        self:add_service(svc)
    end
    do
        local svc = RpcService:new(self, Service_Name.rpc)
        svc:init()
        self:add_service(svc)
    end
end