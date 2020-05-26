
local make_peer_service_query_result = function(node)
    local ret = {}
    ret.ip = node.st:get_ip()
    ret.port = node.st:get_port()
    ret.host_id = node.st:get_id()
    ret.key = node.st:get_service()
    ret.net_connected = false
    ret.net_cnn_seq = nil
    ret.net_netid = nil
    if node.net then
        ret.net_connected = node.net.connected
        ret.net_cnn_seq = node.net.peer_cnn_seq
        if node.net.cnn then
            ret.net_netid = node.net.cnn:netid()
        end
    end
    return ret
end

local parse_node = function(node)
    local key = node[Etcd_Const.Key]
    local service_state = ZoneServiceState.from_json(node[Etcd_Const.Value])
    return {key=key, service_state=service_state}
end

function ZoneServiceMgr:_etcd_service_state_process_pull(ret)
    -- log_debug("ZoneServiceMgr:_etcd_service_state_process_pull %s", string.to_print(ret))
    if not ret:is_ok() then
        return
    end
    local st_nodes = {}
    local op_ret = ret.op_result
    local dirs = op_ret[Etcd_Const.Node][Etcd_Const.Nodes]
    for _, dir in pairs(dirs) do
        if dir[Etcd_Const.Dir] then
            local nodes = dir[Etcd_Const.Nodes] or {}
            for _, v in pairs(nodes) do
                if not v[Etcd_Const.Dir] then
                    if not is_dir then
                        local node = parse_node(v)
                        assert(not st_nodes[v.key], string.format("dumplicate key %s", v.key))
                        st_nodes[node.key] = node
                        -- log_debug("ZoneServiceMgr:_etcd_service_state_process_pull k, v %s, %s",  node.key, string.to_print(node))
                    end
                end
            end
        end
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
    -- log_debug("ZoneServiceMgr:_etcd_service_state_process_watch %s", string.to_print(ret))
    if not ret:is_ok() then
        return
    end
    local op_ret = ret.op_result
    local action = op_ret[Etcd_Const.Action]
    if Etcd_Const.Set == action then
        local node = parse_node(op_ret[Etcd_Const.Node])
        if self.service_state_list[node.key] then
            self:_etcd_service_state_update(node)
        else
            self:_etcd_service_state_add(node)
        end
    end
    if Etcd_Const.Delete == action or Etcd_Const.Expire == action then
        self:_etcd_service_state_delete(op_ret[Etcd_Const.Node][Etcd_Const.Key])
    end
end

function ZoneServiceMgr:next_peer_cnn_seq()
    self.peer_cnn_last_seq = self.peer_cnn_last_seq + 1
    return self.peer_cnn_last_seq
end

function ZoneServiceMgr:_etcd_service_state_add(st)
    -- log_debug("ZoneServiceMgr:_etcd_service_state_add %s", st)
    self.service_state_list[st.key] = {key=st.key, st = st.service_state, net = nil }
end

function ZoneServiceMgr:_etcd_service_state_update(st)
    -- log_debug("ZoneServiceMgr:_etcd_service_state_update, %s", st)
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
    exist_st.st = st.service_state
    if not is_host_same then
        local net = exist_st.net
        exist_st.net = nil
        if net then
            Net.cancel_async(net.cnn_async_id)
            Net.close(net.cnn:netid())
        end
    end
end

function ZoneServiceMgr:_etcd_service_state_delete(service_name)
    if not self.service_state_list[service_name] then
        return
    end
    local st = self.service_state_list[service_name]
    self.service_state_list[service_name] = nil
    local net = st.net
    if net then
        Net.cancel_async(net.cnn_async_id)
        Net.close(net.cnn:netid())
    end
    log_debug("ZoneServiceMgr:_etcd_service_state_delete service:%s", service_name)
end


function ZoneServiceMgr:make_peer_cnn(peer_cnn_seq)
    local cnn = PidBinCnn:new()
    cnn:set_open_cb(Functional.make_closure(ZoneServiceMgr._peer_cnn_handler_on_open, self, peer_cnn_seq))
    cnn:set_close_cb(Functional.make_closure(ZoneServiceMgr._peer_cnn_handler_on_close, self, peer_cnn_seq))
    cnn:set_recv_cb(Functional.make_closure(ZoneServiceMgr._peer_cnn_handler_on_recv, self, peer_cnn_seq))
    return cnn
end

function ZoneServiceMgr:_peer_cnn_handler_on_open(peer_cnn_seq, cnn_handler, error_num)
    -- log_debug("ZoneServiceMgr:_peer_cnn_handler_on_open peer_cnn_seq:%s, netid:%s error_num:%s", peer_cnn_seq, cnn_handler:netid(), error_num)
    local st = nil
    for k, v in pairs(self.service_state_list) do
        if v.net and v.net.peer_cnn_seq == peer_cnn_seq  then
            st = v
            break
        end
    end
    if 0 == error_num then
        if not st or not st.net then
            Net.close(cnn_handler:netid())
        else
            st.net.connected = true
            st.net.ping_ms = 0
            st.net.pong_ms = native.logic_ms()
            st.net.cnn:send(ZoneServiceMgr.Pid_Introduce_Self, self.etcd_service_key)
            self.observer_event_proxy:fire(Zone_Service_Mgr_Event_Connected_Service, make_peer_service_query_result(st))
        end
    else
        if st and st.net then
            st.net = nil
        end
    end
end

function ZoneServiceMgr:_peer_cnn_handler_on_close(peer_cnn_seq, cnn_handler, error_num)
    local st = nil
    for k, v in pairs(self.service_state_list) do
        if v.net and v.net.peer_cnn_seq == peer_cnn_seq  then
            st = v
            break
        end
    end
    if st then
        st.net = nil
        self.observer_event_proxy:fire(Zone_Service_Mgr_Event_Disconnected_Service, make_peer_service_query_result(st))
    end
    if st and st.st then
        log_debug("ZoneServiceMgr: connected peer service is closed. service:%s, netid:%s, error_num:%s, st:%s",
                st.st:get_service(), cnn_handler:netid(), error_num, st)
    end
end

function ZoneServiceMgr:_peer_cnn_handler_on_recv(peer_cnn_seq, cnn_handler, pid, bin)
    -- log_debug("ZoneServiceMgr:_peer_cnn_handler_on_recv +++ netid:%s, pid:%s", cnn_handler:netid(), pid)
    local st = nil
    for k, v in pairs(self.service_state_list) do
        if v.net and v.net.peer_cnn_seq == peer_cnn_seq  then --todo:优化效率
            st = v
            break
        end
    end
    if not st then
        Net.close(cnn_handler:netid())
        return
    end
    if ZoneServiceMgr.Pid_Ping == pid then
        st.net.cnn:send(ZoneServiceMgr.Pid_Pong)
    elseif ZoneServiceMgr.Pid_Pong == pid then
        st.net.pong_ms = native.logic_ms()
    elseif ZoneServiceMgr.Pid_Introduce_Self == pid then
        if st.st:get_service() ~= bin then
            st.net = nil
            Net.close(cnn_handler:netid())
        else
            log_debug("ZoneServiceMgr: connect peer service:%s, netid:%s", bin, st.net.cnn:netid())
        end
    else
        log_error("ZoneServiceMgr:_peer_cnn_handler_on_recv should not reach here! peer_cnn_id:%s, pid:%s", peer_cnn_seq, pid)
    end
end

function ZoneServiceMgr:_on_frame_process_peer_connect(now_ms)
    for _, v in pairs(self.service_state_list) do
        if not v.net then
            local net = {}
            v.net = net
            net.peer_cnn_seq = self:next_peer_cnn_seq()
            net.cnn = self:make_peer_cnn(net.peer_cnn_seq)
            net.cnn_async_id = Net.connect_async(v.st:get_ip(), tonumber(v.st:get_port()), net.cnn)
            net.ping_ms = nil
            net.pong_ms = nil
            net.connected = false
        end
        if v.net.connected and v.net.ping_ms and now_ms - v.net.ping_ms >= self.Cnn_Ping_Ms_Span then
            v.net.ping_ms = now_ms
            v.net.cnn:send(ZoneServiceMgr.Pid_Ping)
        end
        if v.net.connected and v.net.pong_ms and now_ms - v.net.pong_ms > self.Cnn_Alive_Without_Pong then
            Net.cancel_async(v.net.cnn_async_id)
            Net.close(v.net.cnn:netid())
            v.net.connected = false
        end
    end
end

function ZoneServiceMgr:send_by_id(service_id, pid, bin)
    local found_key = nil
    for k, v in pairs(self.service_state_list) do --todo:优化效率
        if v.st and v.st:get_id() == service_id then
            found_key = k
            break
        end
    end
    if not found_key then
        return false
    end
    return self:send(found_key, pid, bin)
end

function ZoneServiceMgr:send(service_name, pid, bin)
    local st = self.service_state_list[service_name]
    if not st or not st.net or not st.net.cnn or not st.net.connected then
        log_debug("ZoneServiceMgr:send not found service %s", service_name)
        return false
    end
    return st.net.cnn:send(pid, bin)
end

function ZoneServiceMgr:get_peer_service(service_role, service_idx)
    local ret = nil
    service_idx = service_idx or 0
    local service_key = path.combine(self.etcd_root_dir, service_role, service_idx)
    local st = self.service_state_list[service_key]
    if st and st.net and st.net.connected then
        ret = make_peer_service_query_result(st)
    end
    return ret
end

function ZoneServiceMgr:rand_peer_service(service_role)
    local service_group = self:get_peer_service_group(service_role)
    local keys = table.keys(service_group)
    local ret = nil
    if #keys > 0 then
        local rand_idx = math.random(1, #keys)
        local key = keys[rand_idx]
        ret = service_group[key]
    end
    return ret
end

function ZoneServiceMgr:get_peer_service_group(service_role)
    local service_key_prefix = self.etcd_root_dir
    if service_role then
        service_key_prefix = path.combine(self.etcd_root_dir, service_role)
        service_key_prefix = string.rtrim(service_key_prefix, "\\/") .. "/"
    end
    local ret = {}
    for k, v in pairs(self.service_state_list) do
        if v.net and v.net.connected then
            local start_idx = string.find(k, service_key_prefix)
            if 1 == start_idx then
                ret[k] = make_peer_service_query_result(v)
            end
        end
    end
    return ret
end

