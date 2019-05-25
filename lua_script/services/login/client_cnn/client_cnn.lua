
ClientCnn = ClientCnn or class("ClientCnn")

function ClientCnn:ctor()
    self.cnn = nil
    self.netid = nil
    self.last_recv_sec = 0
end

function ClientCnn:send(pid, tb)
    local is_ok, block = PROTO_PARSER:encode(pid, tb)
    if not is_ok then
        return false
    end
    return self.cnn:send(pid, block)
end