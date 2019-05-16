
AuthService = AuthService or class("AuthService", ServiceBase)

for _, v in ipairs(require("services.auth.service_require_files")) do
    require(v)
end

function create_service_main()
    return AuthService:new()
end

function AuthService:ctor()
    AuthService.super.ctor(self)
    self.http_svr = nil
end

function AuthService:setup_modules()
    self:_init_http_net()
end

function AuthService:start()
    AuthService.super.start(self)
    -- self:for_test()
end
