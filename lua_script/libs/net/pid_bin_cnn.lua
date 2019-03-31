
PidBinCnn = PidBinCnn or class("PidBinCnn", net_handler)

function PidBinCnn:ctor()
    self.super:ctor()
    self.recv_cb = nil
    self.native_handler = native.make_shared_lua_tcp_connect()
    self.native_handler:init(self)
end

function PidBinCnn:set_recv_cb(cb)
    self.recv_cb = cb
end

function PidBinCnn:on_recv(pid, bin)
    return self.recv_cb (self, pid, bin)
end

function PidBinCnn:Reset()
    self.super:Reset()
    self.recv_cb = nil
    self.native_tcp_cnn = nil
end

function PidBinCnn:cnn_handler_shared_ptr()
    assert(self.native_handler)
    return native.to_connect_handler_shared_ptr(self.native_handler)
end

function PidBinCnn:cnn_handler_weak_ptr()
    return native.to_connect_handler_weak_ptr(self.native_handler)
end

function PidBinCnn:send(pid, bin)
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

