
Functional = Functional or {}

function Functional.make_closure(fn, ...)
    local t = {...}
    local ret = function(...)
        local is_ok, fn_ret = xpcall(fn, error_handler, table.unpack(t), ...)
        if is_ok then
            return fn_ret
        end
        return nil
    end
    return ret
end