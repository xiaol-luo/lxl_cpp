
---@class GateLogicService:LogicServiceBase
GateLogicService = GateLogicService or class("LogicService", LogicServiceBase)

function GateLogicService:_on_init()
    GateLogicService.super._on_init(self)

    do
        local logic = GateClientMgr:new(self, Gate_Logic_Name.gate_client_mgr)
        logic:init()
        self:add_logic(logic)
    end

    do
        local logic = GateLogic:new(self, Gate_Logic_Name.gate)
        logic:init()
        self:add_logic(logic)
    end

    do
       local logic = CreateRoleAgentLogic:new(self, Gate_Logic_Name.create_role_agent)
        logic:init()
        self:add_logic(logic)
    end
end