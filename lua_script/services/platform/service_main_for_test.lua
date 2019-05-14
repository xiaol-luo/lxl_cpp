
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
        print("xxxxxxxxxxxxxxxx", ex_coroutine_resume(co, "hello", 123))
    end)
    local co_ok, hello, num = nil, nil, nil
    co_ok, hello, num = ex_coroutine_yield(co)
    log_debug("params 2 %s %s %s", co_ok, hello, num)

    table.insert(SERVICE_MAIN.delay_execute_fns,function ()
        print("yyyyyyyyyyyyy 1", co:status())
        print("yyyyyyyyyyy", ex_coroutine_resume(co, "world", 456))
    end)
    co_ok, hello, num = ex_coroutine_yield(co, "rsp xxxx1")
    log_debug("params 3 %s %s %s", co_ok, hello, num)

    co:set_custom_data({
        return_int = 12345,
        return_str = "ssfsdf"
    })
    log_debug("for_test_main_logic 4")
    return 1, 2, 3, 4
end

local for_test_over_cb = function(co)
    log_debug("for_test_over_cb %s\n %s", co:get_custom_data(), co:get_return_vals())
end

function PlatformService:for_test()
    CoroutineExMgr.start()
    log_debug("for_test 1")
    local co = CoroutineExMgr.create_co(for_test_main_logic, for_test_over_cb)
    local is_ok, msg = ex_coroutine_start(co, co)
    log_debug("for_test 2 %s %s", is_ok, msg)
end
