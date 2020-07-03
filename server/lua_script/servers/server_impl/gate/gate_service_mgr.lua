
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

    return true
end
