
net_handler = net_handler or class("net_handler")

function net_handler:ctor()
    self.open_cb = nil
    self.close_cb = nil
    self.native_handler = nil
end

function net_handler:set_open_cb(cb)
    self.open_cb = cb
end

function net_handler:set_close_cb(cb)
    self.close_cb = cb
end

function net_handler:on_open(err_num)
    Functional.safe_call(self.open_cb, err_num)
end

function net_handler:on_close(err_num)
    Functional.safe_call(self.close_cb, err_num)
end

function net_handler:netid()
    local ret = 0
    if nil ~= self.native_handler then
        ret = self.native_handler.netid
    end
    return ret
end

function net_handler:net_handler_shared_ptr()
    assert(self.native_handler)
    return native.to_net_handler_shared_ptr(self.native_handler)
end

function net_handler:net_handler_weak_ptr()
    assert(self.native_handler)
    return native.to_net_handler_shared_ptr(self.to_net_handler_weak_ptr)
end

function net_handler:cnn_handler_shared_ptr()
    assert(false, "should not reach here")
end

function net_handler:cnn_handler_weak_ptr()
    assert(false, "should not reach here")
end

function net_handler:listen_handler_shared_ptr()
    assert(false, "should not reach here")
end

function net_handler:listen_handler_weak_ptr()
    assert(false, "should not reach here")
end

