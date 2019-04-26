
Functional = Functional or {}
local help_fns = {}

local return_vals_info = function (...)
    local n = select('#', ...)
    return n, {...}
end

function Functional.make_closure(fn, ...)
    local t = {...}
    local t_len = select('#', ...)
    assert(t_len < #help_fns, string.format("write more help fns #t=%d", t_len))
    local ret = help_fns[t_len](fn, t, error_handler)
    return ret
end

help_fns[0] = function(fn, t, error_fn)
    return function(...)
        local n, tb = return_vals_info(xpcall(f, error_fn, ...))
        local is_ok = tb[1]
        if is_ok and #tb > 1 then
            return table.unpack(tb, 2, n-1)
        end
        return nil
    end
end
help_fns[1] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
help_fns[2] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
help_fns[3] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
help_fns[4] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
help_fns[5] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
help_fns[6] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], t[6], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
help_fns[7] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], t[6], t[7], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
help_fns[8] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end

local fn_with_args_0 = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_handler, ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end

local fn_with_args_0 = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_handler, ...)
        if not is_ok then fn_ret = nil end
        return fn_ret
    end
end
