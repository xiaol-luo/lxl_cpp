
NetHandler = NetHandler or class("NetHandler")

function NetHandler:ctor()
    self.open_cb = nil
    self.close_cb = nil
    self.native_handler = nil
end

function NetHandler:reset()
    if self.native_handler then
        Net.close(self.native_handler:netid())
        self.native_handler = nil
    end
    self.open_cb = nil
    self.close_cb = nil
end

function NetHandler:set_open_cb(cb)
    self.open_cb = cb
end

function NetHandler:set_close_cb(cb)
    self.close_cb = cb
end

function NetHandler:on_open(error_num)
    Functional.safe_call(self.open_cb, self, error_num)
end

function NetHandler:on_close(error_num)
    Functional.safe_call(self.close_cb, self, error_num)
end

function NetHandler:netid()
    local ret = 0
    if nil ~= self.native_handler then
        ret = self.native_handler.netid
    end
    return ret
end

function NetHandler:net_handler_shared_ptr()
    assert(self.native_handler)
    return native.to_net_handler_shared_ptr(self.native_handler)
end

function NetHandler:net_handler_weak_ptr()
    assert(self.native_handler)
    return native.to_net_handler_shared_ptr(self.to_net_handler_weak_ptr)
end

function NetHandler:cnn_handler_shared_ptr()
    assert(false, "should not reach here")
end

function NetHandler:cnn_handler_weak_ptr()
    assert(false, "should not reach here")
end

function NetHandler:listen_handler_shared_ptr()
    assert(false, "should not reach here")
end

function NetHandler:listen_handler_weak_ptr()
    assert(false, "should not reach here")
end

