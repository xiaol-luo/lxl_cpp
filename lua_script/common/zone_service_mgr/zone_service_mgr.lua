
ZoneServiceMgr = ZoneServiceMgr or class("ZoneServiceMgr")

function ZoneServiceMgr:ctor(etcd_setting, listen_port, service_name)
    self.etcd_setting = etcd_setting
    self.listen_port = listen_port
    self.service_name = service_name
    self.is_started = false
    self.listen_handler = nil
    self.etcd_client = nil
    self.etcd_root_dir = etcd_setting[Service_Cfg_Const.Etcd_Root_Dir]
    self.etcd_service_key = string.format("%s/%s", string.rtrim(self.etcd_root_dir, '/'), string.ltrim(service_name, '/'))
    self.etcd_ttl = etcd_setting[Service_Cfg_Const.Etcd_Ttl]
    self.etcd_service_val = string.format("%s:%s", native.local_net_ip(), self.listen_port)
end

function ZoneServiceMgr:start()
    if self.is_started then
        return
    end
    self.listen_handler = TcpListen:new()
    self.listen_handler:set_gen_cnn_cb(Functional.make_closure(ZoneServiceMgr._listen_handler_gen_cnn, self))
    self.listen_handler:set_open_cb(Functional.make_closure(ZoneServiceMgr._listen_handler_on_open, self))
    self.listen_handler:set_close_cb(Functional.make_closure(ZoneServiceMgr._listen_handler_on_close, self))
    native.net_listen("0.0.0.0", self.listen_port, self.listen_handler:get_native_listen_weak_ptr())
    self.etcd_client = EtcdClient:new(
            self.etcd_setting[Service_Cfg_Const.Etcd_Host],
            self.etcd_setting[Service_Cfg_Const.Etcd_User],
            self.etcd_setting[Service_Cfg_Const.Etcd_Pwd])
    self.etcd_client:set(self.etcd_service_key, self.etcd_service_val, self.etcd_ttl, false,
            Functional.make_closure(ZoneServiceMgr._etcd_service_val_set_cb, self))
    self.is_started = true
end

function ZoneServiceMgr:stop()
    self.listen_handler = nil
end

function ZoneServiceMgr:on_frame()
    if not self.is_started then
        return
    end
    -- local cnn = self:make_cnn()
    -- native.net_connect("127.0.0.1", self.listen_port, cnn:get_native_connect_weak_ptr())
    -- cnn:send(1, "xxxx")
    self.etcd_client:refresh_ttl(self.etcd_service_key, self.etcd_ttl, false,
            Functional.make_closure(ZoneServiceMgr._etcd_service_val_refresh_ttl_cb, self))
end

function ZoneServiceMgr:_etcd_service_val_set_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_set_service_val_cb %s %s", op_id, string.toprint(ret))
end

function ZoneServiceMgr:_etcd_service_val_refresh_ttl_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_service_val_refresh_ttl_cb %s %s", op_id, string.toprint(ret))
end

function ZoneServiceMgr:_listen_handler_gen_cnn(listen_handler)
    return self:make_cnn()
end

function ZoneServiceMgr:_listen_handler_on_open(listen_handler, err_num)
    log_debug("ZoneServiceMgr:_listen_handler_on_open %s", err_num)
end

function ZoneServiceMgr:_listen_handler_on_close(listen_handler, err_num)
    log_debug("ZoneServiceMgr:_listen_handler_on_close %s", err_num)
end

function ZoneServiceMgr:_cnn_handler_on_open(cnn_handler, err_num)
    log_debug("ZoneServiceMgr:_cnn_handler_on_open %s", err_num)
end

function ZoneServiceMgr:_cnn_handler_on_close(cnn_handler, err_num)
    log_debug("ZoneServiceMgr:_cnn_handler_on_close %s", err_num)
end

function ZoneServiceMgr:_cnn_handler_on_recv(cnn_handler, pid, bin)
    log_debug("ZoneServiceMgr:_cnn_handler_on_recv %s", pid)
    native.net_close(cnn_handler:netid())
end

function ZoneServiceMgr:make_cnn()
    local cnn = TcpConnect:new()
    cnn:set_open_cb(Functional.make_closure(ZoneServiceMgr._cnn_handler_on_open, self))
    cnn:set_close_cb(Functional.make_closure(ZoneServiceMgr._cnn_handler_on_close, self))
    cnn:set_recv_cb(Functional.make_closure(ZoneServiceMgr._cnn_handler_on_recv, self))
    return cnn
end


