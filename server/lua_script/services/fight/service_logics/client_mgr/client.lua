
Client = Client or class("Client")

function Client:ctor(client_mgr, netid, cnn)
    self.client_mgr = client_mgr
    self.netid = netid
    self.cnn = cnn
    self.state = Gate_Client_State.free
    self.fight = nil
    self.error_msg = ""
end

function Client:release()
    if self.cnn then
        self.cnn:close()
    end
    self.state = Gate_Client_State.released
    self.cnn = nil
    self.fight = nil
end

function Client:send(pid, tb)
    if not self.cnn then
        return false
    end
    return self.cnn:send(pid, tb)
end

function Client:send_msg_bytes(pid, msg_bytes)
    if not self.cnn then
        return false
    end
    return self.cnn:send_msg_bytes(pid, msg_bytes)
end

