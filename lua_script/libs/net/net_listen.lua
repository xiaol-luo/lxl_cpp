
NetListen = NetListen or class("NetListen", net_handler)

function NetListen:ctor()
    self.super:ctor()
    self.gen_cnn_cb = nil
    self.native_handler = native.make_shared_lua_tcp_listen()
    self.native_handler:init(self)
end

function NetListen:set_gen_cnn_cb(cb)
    self.gen_cnn_cb = cb
end

function NetListen:gen_cnn()
    local is_ok, cnn = Functional.safe_call(self.gen_cnn_cb, self)
    if is_ok then
        return cnn:cnn_handler_shared_ptr()
    end
    return nil
end

function NetListen:Reset()
    self.super:Reset()
    self.gen_cnn_cb = nil
    self.native_tcp_listen = nil
end

function NetListen:listen_handler_shared_ptr()
    assert(self.native_handler)
    return native.to_listen_handler_shared_ptr(self.native_handler)
end

function NetListen:listen_handler_weak_ptr()
    assert(self.native_handler)
    return native.to_listen_handler_weak_ptr(self.native_handler)
end