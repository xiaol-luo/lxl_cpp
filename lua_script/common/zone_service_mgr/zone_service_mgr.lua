
ZoneServiceMgr = ZoneServiceMgr or class("ZoneServiceMgr")
ZoneServiceMgr.Pid_Ping = 1
ZoneServiceMgr.Pid_Pong = 2
ZoneServiceMgr.Introduce_Self = 3

function ZoneServiceMgr:ctor(etcd_setting, id, listen_port, service_name)
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
    self.etcd_service_val = ZoneServiceState:new(id, self.service_name, native.local_net_ip(), self.listen_port)
    self.etcd_last_refresh_ttl_ms = 0
    self.etcd_refresh_ttl_span_ms = self.etcd_ttl * 1000 / 4
    self.etcd_last_fetch_service_states_ms = 0
    self.etcd_fetch_service_states_span_ms = 5 * 1000
    self.etcd_watch_op_id = nil
    self.etcd_watch_wait_index = nil
    self.service_state_list = {}
    self.peer_cnn_last_seq = 0
    self.etcd_watch_timerid = nil
    self.check_cnn_last_ms = 0
    self.Check_Cnn_Ms_Span = 1000
    self.accept_cnn_states = {} -- cnn, ping_ms, pong_ms
    self.Cnn_Ping_Ms_Span = 2 * 1000
    self.Cnn_Alive_Without_Pong = self.Cnn_Ping_Ms_Span * 2
end

function ZoneServiceMgr:start()
    if self.is_started then
        return
    end
    self.listen_handler = NetListen:new()
    self.listen_handler:set_gen_cnn_cb(Functional.make_closure(ZoneServiceMgr._listen_handler_gen_cnn, self))
    self.listen_handler:set_open_cb(Functional.make_closure(ZoneServiceMgr._listen_handler_on_open, self))
    self.listen_handler:set_close_cb(Functional.make_closure(ZoneServiceMgr._listen_handler_on_close, self))
    Net.listen("0.0.0.0", self.listen_port, self.listen_handler)
    self:_etcd_pull_service_states()
    self.is_started = true
end

function ZoneServiceMgr:stop()
    self.is_started = false
    self.listen_handler = nil
    self.etcd_client:delete(self.etcd_service_key, false, nil)
    if self.etcd_watch_timerid then
        native.timer_remove(self.etcd_watch_timerid)
        self.etcd_watch_timerid = nil
    end
    for _, v in pairs(self.service_state_list) do
        local net = v.net
        native.net_cancel_async(net.cnn_async_id)
        native.net_close(net.cnn:netid())
        net.cnn = nil
    end
    self.service_state_list = {}
end

function ZoneServiceMgr:on_frame()
    if not self.is_started then
        return
    end

    local now_ms = native.logic_ms()
    if self.etcd_service_val:get_online() then
        if now_ms - self.etcd_last_refresh_ttl_ms >= self.etcd_refresh_ttl_span_ms then
            self.etcd_last_refresh_ttl_ms = now_ms
            self:etcd_service_val_refresh_ttl()
        end
    end

    if now_ms - self.check_cnn_last_ms >= self.Check_Cnn_Ms_Span then
        self.check_cnn_last_ms = now_ms
        self:_on_frame_process_accept_connect(now_ms)
        self:_on_frame_process_peer_connect(now_ms)
    end
end

function ZoneServiceMgr:etcd_service_val_update()
    log_debug("ZoneServiceMgr:etcd_service_val_update()")
    self.etcd_client:set(self.etcd_service_key, self.etcd_service_val:to_json(), self.etcd_ttl, false,
            Functional.make_closure(ZoneServiceMgr._etcd_service_val_set_cb, self))
end

function ZoneServiceMgr:_etcd_service_val_set_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_set_service_val_cb %s %s", op_id, string.toprint(ret))
    if not self.is_started then
        return
    end
    if not ret:is_ok() then
        self:etcd_service_val_update()
    end
end

function ZoneServiceMgr:_etcd_pull_service_states()
    self.etcd_watch_op_id = nil
    self.etcd_client:get(self.etcd_root_dir, true, Functional.make_closure(ZoneServiceMgr._etcd_pull_service_status_cb, self))
end

function ZoneServiceMgr:_etcd_pull_service_status_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_pull_service_status_cb %s %s", op_id, ret:is_ok())
    if not self.is_started then
        return
    end
    if not ret:is_ok() then
        self:_etcd_pull_service_states()
    else
        self.etcd_watch_wait_index = tonumber(ret.op_result[EtcdConst.Head_Index]) + 1
        self:_etcd_watch_service_states()
        self:_etcd_service_state_process_pull(ret)
    end
end

function ZoneServiceMgr:_etcd_watch_service_states()
    assert(self.etcd_watch_wait_index)
    self.etcd_watch_op_id = self.etcd_client:watch(self.etcd_root_dir, true, self.etcd_watch_wait_index,
            Functional.make_closure(ZoneServiceMgr._etcd_watch_service_states_cb, self))
end

function ZoneServiceMgr:_etcd_watch_service_states_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_watch_service_states_cb %s %s", op_id, ret:is_ok())
    if not self.is_started then
        return
    end
    if op_id ~= self.etcd_watch_op_id then
        return
    end
    if not ret:is_ok() then
        self:_etcd_pull_service_states()
    else
        self.etcd_watch_wait_index = tonumber(ret.op_result[EtcdConst.Head_Index]) + 1
        self.etcd_watch_timerid = native.timer_next(Functional.make_closure(ZoneServiceMgr._etcd_watch_service_states, self), 0)
        self:_etcd_service_state_process_watch(ret)
    end
end

function ZoneServiceMgr:etcd_service_val_refresh_ttl()
    self.etcd_client:refresh_ttl(self.etcd_service_key, self.etcd_ttl, false,
            Functional.make_closure(ZoneServiceMgr._etcd_service_val_refresh_ttl_cb, self))
end

function ZoneServiceMgr:_etcd_service_val_refresh_ttl_cb(op_id, op, ret)
    log_debug("ZoneServiceMgr:_etcd_service_val_refresh_ttl_cb %s %s", op_id, ret:is_ok())
    if not ret:is_ok() and self.is_started then
        self:etcd_service_val_update()
    end
end

function ZoneServiceMgr:_listen_handler_gen_cnn(listen_handler)
    return self:make_accept_cnn()
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


