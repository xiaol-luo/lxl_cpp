
LoginService = LoginService or class("LoginService", GameServiceBase)

for _, v in ipairs(require("services.fight.service_require_files")) do
    require(v)
end

function create_service_main()
    return LoginService:new()
end

function LoginService:ctor()
    LoginService.super.ctor(self)
end

function LoginService:setup_modules()
    LoginService.super.setup_modules(self)
end

