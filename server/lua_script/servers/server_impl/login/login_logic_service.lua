
---@class LoginLogicService:LogicServiceBase
LoginLogicService = LoginLogicService or class("LogicService", LogicServiceBase)

function LoginLogicService:_on_init()
    LoginLogicService.super._on_init(self)

    do
        local logic = LoginClientMgr:new(self, Login_Logic_Name.client_mgr)
        logic:init()
        self:add_logic(logic)
    end

    do
        local logic = LoginLogic:new(self, Login_Logic_Name.login_logic)
        logic:init()
        self:add_logic(logic)
    end
end