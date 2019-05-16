
local for_test_main_logic = function(co, self)
    log_debug("for_test_main_logic")
end

local for_test_over_cb = function(co)
    log_debug("for_test_over_cb %s\n %s", co:get_custom_data(), co:get_return_vals())
end

function PlatformService:for_test()
    local co = CoroutineExMgr.create_co(for_test_main_logic, for_test_over_cb)
    ex_coroutine_start(co, co, self)
end
