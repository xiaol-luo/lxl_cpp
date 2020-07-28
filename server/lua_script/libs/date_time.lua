
function logic_ms()
    return native.logic_ms()
end

function logic_sec()
    local sec = native.logic_sec()
    return math.ceil(sec)
end

function to_date(date_format, sec)
    if nil == sec then
        sec = logic_sec()
    end
    return to_date(date_format, sec)
end

function to_sec(tb)
    return os.time(tb)
end

function diff_sec(to_sec, from_sec)
    return os.difftime(to_sec, from_sec)
end