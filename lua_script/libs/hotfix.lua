
function hotfix_replace_one_upvalue(new_fn, name, idx, old_fn)
    local _idx = 0
    while true do
        _idx = _idx + 1
        local _name = debug.getupvalue(old_fn, _idx)
        if _name == name then
            debug.upvaluejoin(new_fn, idx, old_fn, _idx)
            return true
        end
    end
    return false
end

function hotfix_function(old_fn, new_fn)
    local idx = 0
    while true do
        idx = idx + 1
        local name = debug.getupvalue(new_fn, idx)
        if not name then
            break
        end
        local old_idx = 0
        while true do
            old_idx = old_idx + 1
            local old_name = debug.getupvalue(old_fn, old_idx)
            if not old_name then
                break
            end
            if name == old_name then
                debug.upvaluejoin(new_fn, idx, old_fn, old_idx)
                break
            end
        end
    end
    -- 用new_fn的proto替换old_fn的proto
    debug.replace_proto(old_fn, new_fn)
    -- 用new_fn的upvalues替换old_fn的upvalues
    debug.copy_upvalues(old_fn, new_fn)
end