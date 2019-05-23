
LoginService = LoginService or class("LoginService", GameServiceBase)

for _, v in ipairs(require("services.login.service_require_files")) do
    require(v)
end

function create_service_main()
    return LoginService:new()
end

function LoginService:ctor()
    LoginService.super.ctor(self)
    self.db_client = nil
    self.query_db = nil
end

function LoginService:setup_modules()
    LoginService.super.setup_modules(self)
    self:_init_db_client()
end

