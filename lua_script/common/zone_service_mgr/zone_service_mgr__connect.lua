
local parse_node = function(node)
    local key = node[EtcdConst.Key]
    local service_state = ZoneServiceState.from_json(node[EtcdConst.Value])
    return {key=key, service_state=service_state}
end

function ZoneServiceMgr:_etcd_service_state_process_pull(ret)
    log_debug("ZoneServiceMgr:_etcd_service_state_process_pull %s", string.toprint(ret))
    if not ret:is_ok() then
        return
    end
    local st_nodes = {}
    local op_ret = ret.op_result
    local nodes = op_ret[EtcdConst.Node][EtcdConst.Nodes]
    for _, v in pairs(nodes or {}) do
        local node = parse_node(v)
        assert(not st_nodes[v.key], string.format("dumplicate key %s", v.key))
        st_nodes[node.key] = node
        log_debug("k, v %s",  key, string.toprint(node))
    end
    local exist_keys = table.keys(self.service_state_list)
    for _, exist_key in pairs(exist_keys) do
        if not st_nodes[exist_key] then
            self:_etcd_service_state_delete(exist_key)
        end
    end
    for k, v in pairs(st_nodes) do
        if self.service_state_list[k] then
            self:_etcd_service_state_update(v)
        else
            self:_etcd_service_state_add(v)
        end
    end
end

function ZoneServiceMgr:_etcd_service_state_process_watch(ret)
    log_debug("ZoneServiceMgr:_etcd_service_state_process_watch %s", string.toprint(ret))
    if not ret:is_ok() then
        return
    end
    local op_ret = ret.op_result
    local action = op_ret[EtcdConst.Action]
    if EtcdConst.Set == action then
        local node = parse_node(op_ret[EtcdConst.Node])
        if self.service_state_list[node.key] then
            self:_etcd_service_state_update(node)
        else
            self:_etcd_service_state_add(node)
        end
    end
    if EtcdConst.Delete == action then
        self:_etcd_service_state_delete(op_ret[EtcdConst.Node][EtcdConst.Key])
    end
end

function ZoneServiceMgr:next_peer_cnn_seq()
    self.peer_cnn_last_seq = self.peer_cnn_last_seq + 1
    return self.peer_cnn_last_seq
end

function ZoneServiceMgr:_etcd_service_state_add(st)
    log_debug("ZoneServiceMgr:_etcd_service_state_add")
    local net = {}
    net.peer_cnn_seq = self:next_peer_cnn_seq()
    net.cnn = self:make_peer_cnn(net.peer_cnn_seq)
    net.cnn_async_id = native.net_connect_async(st.service_state:get_ip(), tonumber(st.service_state:get_port()), net.cnn:get_native_connect_weak_ptr())
    self.service_state_list[st.key] = {key=st.key, st = st.service_state, net = net }
end

function ZoneServiceMgr:_etcd_service_state_update(st)
    log_debug("ZoneServiceMgr:_etcd_service_state_update")
    if not self.service_state_list[st.key] then
        return
    end
    local exist_st = self.service_state_list[st.key]
    local is_host_same = true
    if is_host_same and exist_st.st:get_ip() ~= st.service_state:get_ip() then
        is_host_same = false
    end
    if is_host_same and exist_st.st:get_port() ~= st.service_state:get_port() then
        is_host_same = false
    end
    exist_st.st = st
    if not is_host_same then
        local net = exist_st.net
        native.net_cancel_async(net.cnn_async_id)
        native.net_close(net.cnn:netid())
        net.peer_cnn_seq = self:next_peer_cnn_seq()
        net.cnn = self:make_peer_cnn(exist_st.net.peer_cnn_seq)
        net.cnn_async_id = native.net_connect_async(st.service_state:get_ip(), tonumber(st.service_state:get_port()), net.cnn:get_native_connect_weak_ptr())
    end
end

function ZoneServiceMgr:_etcd_service_state_delete(service_name)
    if not self.service_state_list[service_name] then
        return
    end
    local st = self.service_state_list[service_name]
    self.service_state_list[service_name] = nil
    local net = st.net
    net.peer_cnn_id = -1
    native.net_cancel_async(net.cnn_async_id)
    net.cnn_async_id = -1
    native.net_close(net.cnn:netid())
    net.cnn = nil
end

function ZoneServiceMgr:make_peer_cnn(peer_cnn_id)
    local cnn = TcpConnect:new()
    cnn:set_open_cb(Functional.make_closure(ZoneServiceMgr._peer_cnn_handler_on_open, self, peer_cnn_id))
    cnn:set_close_cb(Functional.make_closure(ZoneServiceMgr._peer_cnn_handler_on_close, self, peer_cnn_id))
    cnn:set_recv_cb(Functional.make_closure(ZoneServiceMgr._peer_cnn_handler_on_recv, self, peer_cnn_id))
    return cnn
end

function ZoneServiceMgr:_peer_cnn_handler_on_open(peer_cnn_id, cnn_handler, err_num)
    log_debug("ZoneServiceMgr:_peer_cnn_handler_on_open %s %s", peer_cnn_id, err_num)
end

function ZoneServiceMgr:_peer_cnn_handler_on_close(peer_cnn_id, cnn_handler, err_num)
    log_debug("ZoneServiceMgr:_peer_cnn_handler_on_close %s", err_num)
end

function ZoneServiceMgr:_peer_cnn_handler_on_recv(peer_cnn_id, cnn_handler, pid, bin)
    log_debug("ZoneServiceMgr:_peer_cnn_handler_on_recv %s", pid)
    native.net_close(cnn_handler:netid())
end