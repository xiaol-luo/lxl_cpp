
ZoneServiceMgr = ZoneServiceMgr or class("ZoneServiceMgr")

function ZoneServiceMgr:ctor(etcd_setting, listen_port, service_name)
    self.etcd_setting = etcd_setting
    self.listen_port = listen_port
    self.service_name = service_name
    self.is_started = false
    self.listen_handler = nil
    self.etcd_client = EtcdClient:new(
            self.etcd_setting[Service_Cfg_Const.Etcd_Host],
            self.etcd_setting[Service_Cfg_Const.Etcd_User],
            self.etcd_setting[Service_Cfg_Const.Etcd_Pwd])
    self.etcd_root_dir = string.rtrim(etcd_setting[Service_Cfg_Const.Etcd_Root_Dir], '/')
    self.etcd_service_key = string.format("%s/%s", self.etcd_root_dir, string.ltrim(service_name, '/'))
    self.etcd_ttl = etcd_setting[Service_Cfg_Const.Etcd_Ttl]
    -- self.etcd_service_val = string.format("%s:%s", native.local_net_ip(), self.listen_port)
    self.etcd_service_val = ZoneServiceState:new(self.service_name, native.local_net_ip(), self.listen_port)
    self.etcd_last_refresh_ttl_ms = 0
    self.etcd_refresh_ttl_span_ms = self.etcd_ttl * 1000 / 4
    self.etcd_last_fetch_service_states_ms = 0
    self.etcd_fetch_service_states_span_ms = 5 * 1000
    self.etcd_watch_op_id = nil
    self.etcd_watch_wait_index = nil
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
    self:_etcd_pull_service_states()
    self.is_started = true
end

function ZoneServiceMgr:stop()
    self.listen_handler = nil
    self.etcd_client:delete(self.etcd_service_key, false, nil)
end

function ZoneServiceMgr:on_frame()
    if not self.is_started then
        return
    end
    -- local cnn = self:make_cnn()
    -- native.net_connect("127.0.0.1", self.listen_port, cnn:get_native_connect_weak_ptr())
    -- cnn:send(1, "xxxx")

    if self.etcd_service_val:get_online() then
        local now_ms = native.logic_ms()
        if now_ms - self.etcd_last_refresh_ttl_ms >= self.etcd_refresh_ttl_span_ms then
            self.etcd_last_refresh_ttl_ms = now_ms
            self:etcd_service_val_refresh_ttl()
        end
    end
end

function ZoneServiceMgr:etcd_service_val_update()
    log_debug("ZoneServiceMgr:etcd_service_val_update()")
    self.etcd_client:set(self.etcd_service_key, self.etcd_service_val:to_json(), self.etcd_ttl, false,
            Functional.make_closure(ZoneServiceMgr._etcd_service_val_set_cb, self))
end

function ZoneServiceMgr:_etcd_service_val_set_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_set_service_val_cb %s %s", op_id, string.toprint(ret))
    if not ret:is_ok() then
        native.timer_next(Functional.make_closure(ZoneServiceMgr.etcd_service_val_update, self), 0)
    end
end

function ZoneServiceMgr:_etcd_pull_service_states()
    self.etcd_client:get(self.etcd_root_dir, true, Functional.make_closure(ZoneServiceMgr._etcd_pull_service_status_cb, self))
end

function ZoneServiceMgr:_etcd_pull_service_status_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_pull_service_status_cb %s %s", op_id, string.toprint(ret))
    if not ret:is_ok() then
        native.timer_next(Functional.make_closure(ZoneServiceMgr._etcd_pull_service_status_cb, self), 0)
    else
        -- todo
        self.etcd_watch_wait_index = ret.op_result[EtcdConst.Head_Index]
        self:_etcd_watch_service_states()
    end
end

function ZoneServiceMgr:_etcd_watch_service_states()
    assert(self.etcd_watch_wait_index)
    self.etcd_watch_op_id = self.etcd_client:watch(self.etcd_root_dir, true, self.etcd_watch_wait_index, Functional.make_closure(ZoneServiceMgr._etcd_watch_service_states_cb, self))
end

function ZoneServiceMgr:_etcd_watch_service_states_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_watch_service_states_cb %s %s", op_id, string.toprint(ret))
    if op_id ~= self.etcd_watch_op_id then
        return
    end
    if not ret:is_ok() then
        self:_etcd_pull_service_states()
    else
        self.etcd_watch_wait_index = ret.op_result[EtcdConst.Head_Index]
        native.timer_next(Functional.make_closure(ZoneServiceMgr._etcd_watch_service_states, self), 0)
    end
end

function ZoneServiceMgr:etcd_service_val_refresh_ttl()
    self.etcd_client:refresh_ttl(self.etcd_service_key, self.etcd_ttl, false,
            Functional.make_closure(ZoneServiceMgr._etcd_service_val_refresh_ttl_cb, self))
end

function ZoneServiceMgr:_etcd_service_val_refresh_ttl_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_service_val_refresh_ttl_cb %s %s", op_id, string.toprint(ret))
end

function ZoneServiceMgr:_listen_handler_gen_cnn(listen_handler)
    return self:make_cnn()
end

function ZoneServiceMgr:_listen_handler_on_open(listen_handler, err_num)
    log_debug("ZoneServiceMgr:_listen_handler_on_open %s", err_num)
    self.etcd_service_val:set_online(0 == err_num)
    self:etcd_service_val_update()
end

function ZoneServiceMgr:_listen_handler_on_close(listen_handler, err_num)
    log_debug("ZoneServiceMgr:_listen_handler_on_close %s", err_num)
    self.etcd_service_val:set_online(false)
    self.etcd_service_val_update()
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


