
local is_enable_traceback = false
function log_set_enable_traceback(is_enable)
    is_enable_traceback = is_enable
end

function string_format(fmt_str, ...)
    local str_list = {}
    local tb = {...}
    local tb_len = select('#', ...)
    for i=1, tb_len do
        local arg = tb[i]
        if "table" ~= type(arg) then
            table.insert(str_list, tostring(arg))
        else
            local Show_Max_Level = 3
            table.insert(str_list, string.to_print(arg, Show_Max_Level))
        end
    end
    local ret = fmt_str
    if #str_list > 0 then
        ret = string.format(fmt_str, table.unpack(str_list))
    end
    if is_enable_traceback then
        ret = debug.traceback(ret)
    end
    return ret
end

function log_debug(fmt_str, ...)
    local log_str = string_format(fmt_str, ...)
    native.log_debug(log_str)
end

function log_info(fmt_str, ...)
    local log_str = string_format(fmt_str, ...)
    native.log_info(log_str)
end

function log_warn(fmt_str, ...)
    local log_str = string_format(fmt_str, ...)
    native.log_warn(log_str)
end

function log_error(fmt_str, ...)
    local log_str = string_format(fmt_str, ...)
    native.log_error(log_str)
end

function log_assert(is_ok, fmt_str, ...)
    if not is_ok then
        log_error(fmt_str, ...)
        assert(false)
    end
end

old_print = print

function print(...)
    local str_list = {}
    for _, arg in pairs({...}) do
        if "table" ~= type(arg) then
            table.insert(str_list, tostring(arg))

        else
            table.insert(str_list, string.to_print(arg, 3))
        end
    end
    local ret = table.concat(str_list, ' ')
    -- old_print(ret)
    log_debug(ret)
end

function log_print(...)
    print(...)
end