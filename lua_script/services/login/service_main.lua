
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
    self.client_cnn_mgr = nil
    self.db_uuid = nil
end

function LoginService:setup_modules()
    self:_init_client_cnn_mgr()
    self:_init_db_client()
    self:_init_db_uuid()
    LoginService.super.setup_modules(self)
end

