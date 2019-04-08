
Functional = Functional or {}
local help_fns = {}

function Functional.make_closure(fn, ...)
    local t = {...}
    t.n = select('#', ...)
    assert(#t < #help_fns, string.format("write more help fns #t=%d", #t))
    local ret = help_fns[#t](fn, t, error_handler)
    return ret
end

help_fns[0] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[1] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[2] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[3] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[4] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[5] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[6] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], t[6], ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[7] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], t[6], t[7], ...)
        return is_ok and fn_ret or nil
    end
end
help_fns[8] = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_fn, t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], ...)
        return is_ok and fn_ret or nil
    end
end

local fn_with_args_0 = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_handler, ...)
        return is_ok and fn_ret or nil
    end
end

local fn_with_args_0 = function(fn, t, error_fn)
    return function(...)
        local is_ok, fn_ret = xpcall(fn, error_handler, ...)
        return is_ok and fn_ret or nil
    end
end
