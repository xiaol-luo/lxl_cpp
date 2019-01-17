
TcpListen = TcpListen or class("TcpListen", net_handler)

function TcpListen:ctor()
    self.super:ctor()
    self.gen_cnn_cb = nil
    self.native_handler = native.make_shared_lua_tcp_listen()
    self.native_handler:init(self)
end

function TcpListen:set_gen_cnn_cb(cb)
    self.gen_cnn_cb = cb
end

function TcpListen:gen_cnn()
    local cnn = self.gen_cnn_cb(self)
    return cnn:get_native_handler()
end

function TcpListen:Reset()
    self.super:Reset()
    self.gen_cnn_cb = nil
    self.native_tcp_listen = nil
end

function net_handler:get_native_listen_weak_ptr()
    return native.to_weak_ptr_net_listen(self.native_handler)
end