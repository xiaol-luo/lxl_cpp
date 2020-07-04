
---@class GateServiceMgr: GateServiceMgrBase
---@field logics GateLogicService
---@field online_world_shadow OnlineWorldShadow
GateServiceMgr = class("GateServiceMgr", ServiceMgrBase)

function GateServiceMgr:ctor(server)
    GateServiceMgr.super.ctor(self, server)
end

function GateServiceMgr:_on_init()
    local online_world_shadown = OnlineWorldShadow:new(self, Service_Name.online_world_shadow)
    online_world_shadown:init()
    self:add_service(online_world_shadown)

    local logic_svc = GateLogicService:new(self, Service_Name.logics)
    logic_svc:init()
    self:add_service(logic_svc)

    do
        local svc = ClientNetService:new(self, Service_Name.client_net)
        local listen_port = tonumber(self.server.init_setting.advertise_client_port)
        svc:init(listen_port)
        self:add_service(svc)
    end

    return true
end
