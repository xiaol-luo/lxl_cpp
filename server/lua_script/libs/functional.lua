
Functional = Functional or {}
Functional.error_handler = Functional.error_handler or nil

function Functional.safe_call(fn, ...)
    return xpcall(fn, Functional.error_handler, ...)
end

function Functional.call(fn, ...)
    return fn(...)
end

function  Functional.varlen_param_info(...)
    local n = select('#', ...)
    return n, {...}
end

local help_fns = {}

function Functional.make_closure(fn, ...)
    assert(fn)
    local t_len, t = Functional.varlen_param_info(...)
    assert(t_len <= #help_fns, string.format("write more help fns #t=%d", t_len))
    local ret = help_fns[t_len](Functional.call, fn, t)
    return ret
end

function Functional.make_safe_closure(fn, ...)
    assert(fn)
    local t_len, t = Functional.varlen_param_info(...)
    assert(t_len < #help_fns, string.format("write more help fns #t=%d", t_len))
    local ret = help_fns[t_len](Functional.safe_call, fn, table.unpack(t))
    return ret
end


help_fns[0] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, ...)
    end
end

help_fns[1] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], ...)
    end
end

help_fns[2] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], t[2], ...)
    end
end

help_fns[3] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], t[2], t[3], ...)
    end
end


help_fns[4] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], t[2], t[3], t[4], ...)
    end
end

help_fns[5] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], t[2], t[3], t[4], t[5], ...)
    end
end

help_fns[6] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], t[2], t[3], t[4], t[5], t[6], ...)
    end
end

help_fns[7] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], t[2], t[3], t[4], t[5], t[6], t[7], ...)
    end
end

help_fns[8] = function(call_fn, fn, t)
    return function(...)
        return call_fn(fn, t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], ...)
    end
end



