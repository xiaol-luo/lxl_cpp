
function error_handler(err_msg)
    err_msg = debug.traceback(err_msg)
    log_error(err_msg)
end

function safe_call(fn, arg1, ...)
    return xpcall(fn, error_handler, arg1, ...)
end