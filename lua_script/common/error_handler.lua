
function error_handler(err_msg)
    err_msg = debug.traceback(err_msg)
    log_error(err_msg)
end
