
PlatformService = PlatformService or class("PlatformService", ServiceBase)

for _, v in ipairs(require("services.platform.service_require_files")) do
    require(v)
end

function create_service_main()
    return PlatformService:new()
end

function PlatformService:ctor()
    PlatformService.super.ctor(self)
    self.db_client = nil
    self.query_db = nil
    self.http_svr = nil
    self.delay_execute_fns = {}
end

function PlatformService:setup_modules()
    self:_init_db_client()
    self:_init_http_net()
end

function PlatformService:start()
    PlatformService.super.start(self)
    self:for_test()
end

function PlatformService:on_frame()
    PlatformService.super.on_frame(self)

    local delay_execute_fns = self.delay_execute_fns
    self.delay_execute_fns = {}
    for _, fn in pairs(delay_execute_fns) do
        fn()
    end
end

