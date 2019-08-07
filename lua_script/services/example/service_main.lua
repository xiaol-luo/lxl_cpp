
ExampleService = ExampleService or class("ExampleService", GameServiceBase)

for _, v in ipairs(require("services.example.service_require_files")) do
    require(v)
end

function create_service_main()
    return ExampleService:new()
end

function ExampleService:ctor()
    ExampleService.super.ctor(self)
end
