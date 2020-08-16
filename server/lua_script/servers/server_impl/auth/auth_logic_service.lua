
---@class AuthLogicService:LogicServiceBase
AuthLogicService = AuthLogicService or class("LogicService", LogicServiceBase)

function AuthLogicService:_on_init()
    AuthLogicService.super._on_init(self)

    do
        local logic = AuthLogic:new(self, Auth_Logic_Name.auth_logic)
        logic:init()
        self:add_logic(logic)
    end
end