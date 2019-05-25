
ExampleService = ExampleService or class("ExampleService", GameServiceBase)

for _, v in ipairs(require("services.login.service_require_files")) do
    require(v)
end

function create_service_main()
    return ExampleService:new()
end

function ExampleService:ctor()
    ExampleService.super.ctor(self)
    self.db_client = nil
    self.query_db = nil
end

function ExampleService:setup_modules()
    ExampleService.super.setup_modules(self)
    self:_init_db_client()
end

