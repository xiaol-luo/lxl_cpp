
local PidBinCnn_gc =  function(self)
    if self.native_handler then
        if self.native_handler then
            self.native_handler:notify_gc()
            self.native_handler = nil
        end
    end
end

PidBinCnn = PidBinCnn or class("PidBinCnn", NetCnn, { __gc = PidBinCnn_gc })

function PidBinCnn:ctor()
    PidBinCnn.super.ctor(self)
    self.native_handler = native.make_shared_lua_tcp_connect()
    self.native_handler:init(self)
    self.recv_cb = nil
end

function PidBinCnn:reset()
    PidBinCnn.super.reset(self)
    self.recv_cb = nil
end

function PidBinCnn:set_recv_cb(cb)
    self.recv_cb = cb
end

function PidBinCnn:on_recv(pid, bin)
    Functional.safe_call(self.recv_cb, self, pid, bin)
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

