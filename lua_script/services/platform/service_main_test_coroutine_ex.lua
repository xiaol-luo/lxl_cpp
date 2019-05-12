
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

local test_query = function()
    local co = CoroutineExMgr.get_running()

    SERVICE_MAIN.timer_proxy:delay(function ()
        log_debug("timer reach here 2")
        table.insert(SERVICE_MAIN.delay_execute_fns, function () ex_coroutine_resume(co, "hello", 123) end)
    end, 1000)

    return ex_coroutine_yield(co)
end

local for_test_main_logic = function()
    local co = CoroutineExMgr.get_running()
    -- ex_coroutine_resume(co)
    log_debug("for_test_main_logic 1")

    table.insert(SERVICE_MAIN.delay_execute_fns,function ()
        print("xxxxxxxxxxxxxxxx 1111", co:status(), params)
        local n, params = ex_coroutine_resume(co, "hello", 123)
        print("xxxxxxxxxxxxxxxx", n, params)
    end)
    local co_ok, hello, num = nil, nil, nil
    co_ok, hello, num = ex_coroutine_yield(co)
    log_debug("params 2 %s %s %s", co_ok, hello, num)

    table.insert(SERVICE_MAIN.delay_execute_fns,function ()
        print("yyyyyyyyyyyyy 1", co:status())
        local n, params = ex_coroutine_resume(co, "world", 456)
        print("yyyyyyyyyyy", n, params)
    end)
    co_ok, hello, num = ex_coroutine_yield(co, "rsp xxxx1")
    log_debug("params 3 %s %s %s", co_ok, hello, num)

    co:set_custom_data({
        return_int = 12345,
        return_str = "ssfsdf"
    })
    log_debug("for_test_main_logic 4")
end

local for_test_over_cb = function(co)
    log_debug("for_test_over_cb %s", co:get_custom_data())
end

local for_test = function()
    CoroutineExMgr.start()
    log_debug("for_test 1")
    local co = CoroutineExMgr.create_co(for_test_main_logic, for_test_over_cb)
    local is_ok, msg = ex_coroutine_start(co, co)
    log_debug("for_test 2 %s %s", is_ok, msg)
end

function PlatformService:start()
    PlatformService.super.start(self)
    for_test()
end

function PlatformService:on_frame()
    PlatformService.super.on_frame(self)
    CoroutineExMgr.on_frame()

    local delay_execute_fns = self.delay_execute_fns
    self.delay_execute_fns = {}
    for _, fn in pairs(delay_execute_fns) do
        fn()
    end
end

