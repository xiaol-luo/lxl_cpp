
Forever_Execute_Timer = -1

function timer_firm(fn, execute_span_ms, execute_times)
    execute_span_ms = math.floor(execute_span_ms)
    execute_times = math.floor(execute_times)
    return native.timer_firm(fn, execute_span_ms, execute_times)
end

function timer_delay(fn, delay_ms)
    return timer_firm(fn, delay_ms, 1)
end

function timer_add(fn, delay_ms, execute_span_ms, execute_times)
    start_ms = math.floor(start_ms)
    execute_span_ms = math.floor(execute_span_ms)
    execute_times = math.floor(execute_times)
    return native.timer_add(fn, delay_ms, execute_span_ms, execute_times)
end

function timer_remove(timer_id)
    native.timer_remove(timer_id)
end