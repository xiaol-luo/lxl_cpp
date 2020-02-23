
Client = Client or class("Client")

function Client:ctor(client_mgr, netid, cnn)
    self.client_mgr = client_mgr
    self.netid = netid
    self.cnn = cnn
    self.state = Client_State.free
    self.fight = nil
    self.error_msg = ""
end

function Client:release()
    if self.cnn then
        self.cnn:close()
    end
    self.state = Client_State.released
    self.cnn = nil
    self.fight = nil
end

function Client:send(pid, tb)
    if not self.cnn then
        return false
    end
    local is_ok, block = true, nil
    if tb then
        is_ok, block = PROTO_PARSER:encode(pid, tb)
    end
    if not is_ok then
        return false
    end
    return self.cnn:send(pid, block)
end

function Client:send_msg_bytes(pid, msg_bytes)
    if not self.cnn then
        return false
    end
    return self.cnn:send(pid, msg_bytes)
end

