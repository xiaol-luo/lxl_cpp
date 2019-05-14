
CoroutineState = {
    Dead = "dead",
    Suspended = "suspended",
    Normal = "normal",
    Running = "running",
}

CoroutineKillReason = {
    ReportError = "report_error",
    Expired = "expried",
    Other = "other",
}

function ex_coroutine_start(co, ...)
    return co:start(...)
end

function ex_coroutine_resume(co, ...)
    -- log_debug("ex_coroutine_resume %s %s", tostring(co),  debug.traceback())
    return co:resume(...)
end

function ex_coroutine_delay_resume(co, ...)
    local key = co:get_key()
    local n, params = Functional.varlen_param_info(...)
    CoroutineExMgr.add_delay_execute_fn(function()
        local ex_co = CoroutineExMgr.get_co(key)
        if ex_co then
            ex_coroutine_resume(ex_co, table.unpack(params, 1, n))
        end
    end)
end

function ex_coroutine_yield(co, ...)
    return co:yield(...)
end

function ex_coroutine_status(co)
    return co:status()
end

function delay_execute(fn)
    CoroutineExMgr.add_delay_execute_fn(fn)
end

function new_coroutine_callback(co)
    return Functional.make_closure(function(...)
        ex_coroutine_delay_resume(co, ...)
    end)
end
