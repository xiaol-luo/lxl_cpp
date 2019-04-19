
timer = timer or {}

function timer_next(fn, start_ms)
    start_ms = math.floor(start_ms)
    return native.timer_next(fn, start_ms)
end

function timer_firm(fn, execute_span_ms, execute_times)
    execute_span_ms = math.floor(execute_span_ms)
    execute_times = math.floor(execute_times)
    return native.timer_firm(fn, execute_span_ms, execute_times)
end

function timer_add(fn, start_ms, execute_span_ms, execute_times)
    start_ms = math.floor(start_ms)
    execute_span_ms = math.floor(execute_span_ms)
    execute_times = math.floor(execute_times)
    return native.timer_add(fn, start_ms, execute_span_ms, execute_times)
end

function timer_remove(timer_id)
    native.timer_remove(timer_id)
end