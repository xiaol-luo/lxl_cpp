
path = path or {}

function path.combine(...)
    local ret = ""
    local is_first = true
    for _, v in ipairs({...}) do
        if is_first then
            is_first = false
            ret = string.rtrim(v, "\\/")
        else
            ret = ret .. "/" .. string.rtrim(v, "\\/")
        end
    end
    return ret
end