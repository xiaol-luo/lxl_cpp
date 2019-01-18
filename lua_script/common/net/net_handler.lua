
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
    self.open_cb(self, err_num)
end

function net_handler:on_close(err_num)
    self.close_cb(self, err_num)
end

function net_handler:netid()
    local ret = 0
    if nil ~= self.native_handler then
        ret = self.native_handler.netid
    end
    return ret
end

function net_handler:get_native_handler()
    return self.native_handler
end

function net_handler:get_native_handler_weak_ptr()
    return native.to_weak_ptr_net_connect(self.native_handler)
end