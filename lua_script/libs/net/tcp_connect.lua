
TcpConnect = TcpConnect or class("TcpConnect", net_handler)

function TcpConnect:ctor()
    self.super:ctor()
    self.recv_cb = nil
    self.native_handler = native.make_shared_lua_tcp_connect()
    self.native_handler:init(self)
end

function TcpConnect:set_recv_cb(cb)
    self.recv_cb = cb
end

function TcpConnect:on_recv(pid, bin)
    return self.recv_cb (self, pid, bin)
end

function TcpConnect:Reset()
    self.super:Reset()
    self.recv_cb = nil
    self.native_tcp_cnn = nil
end

function net_handler:get_native_connect_weak_ptr()
    return native.to_weak_ptr_net_connect(self.native_handler)
end

function net_handler:send(pid, bin)
    if not self.native_handler then
        return false
    end
    local ret = false
    if bin then
        ret = self.native_handler:send(pid, bin)
    else
        ret = self.native_handler:send(pid)
    end
    return ret
end
