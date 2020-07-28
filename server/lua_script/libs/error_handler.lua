
function error_handler(error_msg)
    error_msg = debug.traceback(error_msg)
    log_error(error_msg)
end

function safe_call(fn, arg1, ...)
    return xpcall(fn, error_handler, arg1, ...)
end