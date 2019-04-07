

function ZoneServiceMgr:make_accept_cnn()
    local cnn = PidBinCnn:new()
    cnn:set_open_cb(Functional.make_closure(ZoneServiceMgr._accept_cnn_handler_on_open, self))
    cnn:set_close_cb(Functional.make_closure(ZoneServiceMgr._accept_cnn_handler_on_close, self))
    cnn:set_recv_cb(Functional.make_closure(ZoneServiceMgr._accept_cnn_handler_on_recv, self))
    return cnn
end

function ZoneServiceMgr:_accept_cnn_handler_on_open(cnn_handler, err_num)
    log_debug("ZoneServiceMgr:_accept_cnn_handler_on_open %s", err_num)
    if 0 == err_num then
        local st = {}
        st.cnn = cnn_handler
        st.ping_ms = 0
        st.pong_ms = native.logic_ms()
        st.peer_service_name = nil
        self.accept_cnn_states[cnn_handler:netid()] = st
        st.cnn:send(ZoneServiceMgr.Pid_Introduce_Self, self.etcd_service_key)
    end
end

function ZoneServiceMgr:_accept_cnn_handler_on_close(cnn_handler, err_num)
    log_debug("ZoneServiceMgr:_accept_cnn_handler_on_close %s", err_num)
    self.accept_cnn_states[cnn_handler:netid()] = nil
end

function ZoneServiceMgr:_accept_cnn_handler_on_recv(cnn_handler, pid, bin)
    log_debug("ZoneServiceMgr:_accept_cnn_handler_on_recv netid:%s, pid:%s", cnn_handler:netid(), pid)
    local st = self.accept_cnn_states[cnn_handler:netid()]
    if not st then
        Net.close(cnn_handler:netid())
        return
    end

    if not st.peer_service_name and ZoneServiceMgr.Pid_Introduce_Self ~= pid then
        log_error("ZoneServiceMgr:_accept_cnn_handler_on_recv not know msg from which service. netid:%s, pid:%s", cnn_handler:netid(), pid)
        return
    end

    if ZoneServiceMgr.Pid_Ping == pid then
        st.cnn:send(ZoneServiceMgr.Pid_Pong)
    elseif ZoneServiceMgr.Pid_Pong == pid then
        st.pong_ms = native.logic_ms()
    elseif ZoneServiceMgr.Pid_Introduce_Self == pid then
        log_debug("ZoneServiceMgr:_accept_cnn_handler_on_recv netid:%s, pid:%s, peer_service_name:%s", st.cnn:netid(), pid, bin)
        st.peer_service_name = bin
    else
        log_debug("ZoneServiceMgr:_accept_cnn_handler_on_recv netid:%s, pid:%s", st.cnn:netid(), pid)
        self:_handle_msg_from_service(st.peer_service_name, pid, bin)
    end
end

function ZoneServiceMgr:_on_frame_process_accept_connect(now_ms)
    local dead_netids = {}
    for netid, st in pairs(self.accept_cnn_states) do
        if now_ms - st.pong_ms > self.Cnn_Alive_Without_Pong then
            table.insert(dead_netids, netid)
        else
            if now_ms - st.ping_ms >= self.Cnn_Ping_Ms_Span then
                st.ping_ms = now_ms
                st.cnn:send(ZoneServiceMgr.Pid_Ping)
            end
        end
    end
    for _, netid in ipairs(dead_netids) do
        local st = self.accept_cnn_states[netid]
        self.accept_cnn_states[netid] = nil
        if st and st.cnn then
            Net.close(st.cnn:netid())
        end
    end
end

function ZoneServiceMgr:_handle_msg_from_service(service_name, pid, bin)
    local tb = PROTO_PARSER:decode(pid, bin)
    log_debug("ZoneServiceMgr:_handle_msg_from_service %s %s %s", service_name, pid, tb or "nil")
    -- self:send(service_name, pid, bin)
end

