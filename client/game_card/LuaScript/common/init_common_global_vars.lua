

function send_msg(cnn, pid, tb)
    local is_ok, block = true, nil
    if g_ins.proto_parser:exist(pid) then
        is_ok, block = g_ins.proto_parser:encode(pid, tb)
        if not is_ok then
            return false
        end
    end
    return cnn:send(pid, block)
end
