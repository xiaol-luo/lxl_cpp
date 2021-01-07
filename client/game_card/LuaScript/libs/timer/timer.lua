
Forever_Execute_Timer = -1

function timer_firm(fn, execute_span_sec, execute_times)
    return timer_add(fn, 0, execute_span_sec, execute_times)
end

function timer_delay(fn, delay_sec)
    return timer_add(fn, delay_sec, 0, 0)
end

function timer_add(fn, delay_sec, execute_span_sec, execute_times)
    delay_sec = delay_sec or 0
    execute_span_sec = execute_span_sec or 0
    execute_times = execute_times or -1
    return CS.Lua.LuaHelp.TimerAdd(fn, delay_sec, execute_times, execute_span_sec)
end

function timer_remove(tid)
    return CS.Lua.LuaHelp.TimerRemove(tid)
end

function logic_sec()
    return os.time()
end

function logic_ms()
    return os.time() * 1000
end