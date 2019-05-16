
local test_query = function()
    local co = CoroutineExMgr.get_running()

    SERVICE_MAIN.timer_proxy:delay(function ()
        log_debug("timer reach here 2")
        ex_coroutine_delay_resume(co, "test_query", 8888)
    end, 1000)

    return ex_coroutine_yield(co)
end

local for_test_main_logic = function(co, self)
    -- ex_coroutine_resume(co)
    log_debug("for_test_main_logic 1")

    local co_ok, hello, num = nil, nil, nil

    ex_coroutine_delay_resume(co, "hello", 123)
    co_ok, hello, num = ex_coroutine_yield(co)
    log_debug("params 2 %s %s %s", co_ok, hello, num)

    ex_coroutine_delay_resume(co, "world", 456)
    co_ok, hello, num = ex_coroutine_yield(co, "rsp xxxx1")
    log_debug("params 3 %s %s %s", co_ok, hello, num)

    co_ok, hello, num = test_query()
    log_debug("params 4 %s %s %s", co_ok, hello, num)
    co:set_custom_data({
        return_int = 12345,
        return_str = "ssfsdf"
    })

    local Alc = AccountLogic_Const

    local filter = { [Alc.UserName]="lxl" }
    local opt = MongoOptFind:new()
    opt:set_max_time(10 * 1000)
    opt:set_projection({ [Alc.UserName]=true, [Alc.Pwd]=true })

    co:expired_after_ms(10 * 1000)

    local n, rets = nil, nil
--[[
    self.db_client:find_one(1, self.query_db, Alc.Account, filter, new_coroutine_callback(co), opt)
    n, rets = Functional.varlen_param_info(ex_coroutine_yield(co))
    log_debug("params 5 %s %s", n, rets)
--]]

    n, rets = Functional.varlen_param_info(HttpClient.co_get("http://127.0.0.1:10801/login?username=1246610&appid=1024"))
    log_debug("params 6 %s %s", n, rets)

    log_debug("for_test_main_logic 5")
    return 1, 2, 3, 4
end

local for_test_over_cb = function(co)
    log_debug("for_test_over_cb %s\n %s", co:get_custom_data(), co:get_return_vals())
end

function PlatformService:for_test()
    CoroutineExMgr.start()
    log_debug("for_test 1")
    local co = CoroutineExMgr.create_co(for_test_main_logic, for_test_over_cb)
    local is_ok, msg = ex_coroutine_start(co, co, self)
    log_debug("for_test 2 %s %s", is_ok, msg)
end
