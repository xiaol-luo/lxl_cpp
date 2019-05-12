
CoroutineState = {
    Dead = "dead",
    Suspended = "suspended",
    Normal = "normal",
    Running = "running",
}

CoroutineKillReason = {
    ReportError = "report_error",
    Other = "other",
}

function ex_coroutine_start(co, ...)
    return co:start(...)
end

function ex_coroutine_resume(co, ...)
    -- log_debug("ex_coroutine_resume %s %s", tostring(co),  debug.traceback())
    return co:resume(...)
end

function ex_coroutine_yield(co, ...)
    return co:yield(...)
end

function ex_coroutine_status(co)
    return co:status()
end