
ServiceListenModule = ServiceListenModule or class("ServiceListenModule", ServiceModule)

function ServiceListenModule:ctor(module_mgr, module_name)
    ServiceListenModule.super.ctor(self, module_mgr, module_name)
    self.listen_port = nil
    self.listen_handler = nil
end

function ServiceListenModule:init(listen_port)
    ServiceListenModule.super.init(self)
    self.listen_port = listen_port
end

function ServiceListenModule:start()
    self.listen_handler = NetListen:new()
    self.listen_handler:set_gen_cnn_cb(Functional.make_closure(self._listen_handler_gen_cnn, self))
    self.listen_handler:set_open_cb(Functional.make_closure(self._listen_handler_on_open, self))
    self.listen_handler:set_close_cb(Functional.make_closure(self._listen_handler_on_close, self))
    local ret = Net.listen("0.0.0.0", self.listen_port, self.listen_handler)
    if ret <= 0 then
        self.error_num = 1
        self.error_msg = string.format("ServiceListenModule listen on prot %s fail", self.listen_port)
    else
        ServiceListenModule.super.start(self)
    end
end

function ServiceListenModule:stop()
    ServiceListenModule.super.stop(self)
    if self.listen_handler then
        Net.close(self.listen_handler:netid())
        self.listen_handler = nil
    end
end

function ServiceListenModule:release()
    ServiceListenModule.super.release(self)
end

function ServiceListenModule:on_update()
    ServiceListenModule.super.on_update(self)
end

function ServiceListenModule:_listen_handler_gen_cnn(listen_handler)
    return self:_make_accept_cnn()
end

function ServiceListenModule:_listen_handler_on_open(listen_handler, error_num)

end

function ServiceListenModule:_listen_handler_on_close(listen_handler, error_num)

end

function ServiceListenModule:_make_accept_cnn()
    local cnn = PidBinCnn:new()
    cnn:set_open_cb(Functional.make_closure(self.cnn_on_open, self))
    cnn:set_close_cb(Functional.make_closure(self.cnn_on_close, self))
    cnn:set_recv_cb(Functional.make_closure(self.cnn_on_recv, self))
    return cnn
end

function ServiceListenModule:cnn_on_open(cnn, error_num)
    -- should override by subclass
end

function ServiceListenModule:cnn_on_close(cnn, error_num)
    -- should override by subclass
end

function ServiceListenModule:cnn_on_recv(cnn, pid, bin)
    -- should override by subclass
end