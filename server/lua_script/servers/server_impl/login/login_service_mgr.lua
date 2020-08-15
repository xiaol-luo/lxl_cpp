
---@class LoginServiceMgr: ServiceMgrBase
---@field logics LoginLogicService
---@field server LoginServer
LoginServiceMgr = class("LoginServiceMgr", ServiceMgrBase)

function LoginServiceMgr:ctor(server)
    LoginServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_http_service)
end

function LoginServiceMgr:_on_init()
    do
        local svc = ClientNetService:new(self, Service_Name.client_net)
        local listen_port = tonumber(self.server.init_setting.advertise_client_port)
        svc:init(listen_port)
        self:add_service(svc)
    end

    do
        local svc = LoginLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
