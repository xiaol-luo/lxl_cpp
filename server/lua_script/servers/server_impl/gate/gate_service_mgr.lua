
---@class GateServiceMgr: GateServiceMgrBase
---@field logics GateLogicService
---@field world_online_shadow OnlineWorldShadow
GateServiceMgr = class("GateServiceMgr", ServiceMgrBase)

function GateServiceMgr:ctor(server)
    GateServiceMgr.super.ctor(self, server)
end

function GateServiceMgr:_on_init()
    do
        local svc = OnlineWorldShadow:new(self, Service_Name.online_world_shadow)
        svc:init()
        self:add_service(svc)
    end

    do
        local svc = ClientNetService:new(self, Service_Name.client_net)
        local listen_port = tonumber(self.server.init_setting.advertise_client_port)
        svc:init(listen_port)
        self:add_service(svc)
    end

    do
        local svc = GateLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
