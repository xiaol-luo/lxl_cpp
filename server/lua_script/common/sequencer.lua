
function make_sequence(last_id)
    assert(IsNil(last_id) or IsNumber(last_id))
    local _last_id = last_id or 0
    local fn = function()
        _last_id = _last_id + 1
        return _last_id
    end
    return fn
end