Client_Cnn_Tolerate_No_Recv_Sec = 15

ClientCnnMgr = ClientCnnMgr or class("ClientCnnMgr", ServiceListenModule)

function ClientCnnMgr:ctor(module_mgr, module_name)
    ClientCnnMgr.super.ctor(self, module_mgr, module_name)
    self.last_check_client_cnn_expired_sec = 0
end

function ClientCnnMgr:init(listen_port)
    ClientCnnMgr.super.init(self, listen_port)
    self.client_cnns = {}
    self.process_msg_fns = {}
end

function ClientCnnMgr:set_process_fn(pid, fn)
    -- fn format function(netid, pid, msg)
    if nil ~= fn then
        assert(not self.process_msg_fns[pid])
    end
    self.process_msg_fns[pid] = fn
end

function ClientCnnMgr:start()
    ClientCnnMgr.super.start(self)
    self.client_cnns = {}
end

function ClientCnnMgr:stop()
    ClientCnnMgr.super.stop(self)
    for _, v in pairs(self.client_cnns) do
        if v.cnn then
            Net.close(v.cnn:netid())
        end
    end
    self.client_cnns = {}
    self.process_msg_fns = {}
end

function ClientCnnMgr:on_update()
    ClientCnnMgr.super.on_update(self)
    local Check_Expired_Span_Sec = 2
    local now_sec = logic_sec()
    if now_sec - self.last_check_client_cnn_expired_sec >= Check_Expired_Span_Sec then
        local expired_netids = {}
        for netid, client_cnn in pairs(self.client_cnns) do
            if now_sec - client_cnn.last_recv_sec >= Client_Cnn_Tolerate_No_Recv_Sec then
                table.insert(expired_netids, netid)
            end
        end
        for _, netid in ipairs(expired_netids) do
            Net.close(netid)
        end
    end
end

function ClientCnnMgr:cnn_on_open(cnn, error_num)
    local netid = cnn:netid()
    if 0 == error_num then
        local client_cnn = ClientCnn:new()
        client_cnn.cnn = cnn
        client_cnn.netid = cnn:netid()
        client_cnn.last_recv_sec = logic_sec()
        self.client_cnns[netid] = client_cnn
    else
        log_debug("ClientCnnMgr:cnn_on_open netid:%s error:%s", netid, error_num)
    end
    self.event_proxy:fire(Client_Cnn_Event_New_Client , netid, error_num)
end

function ClientCnnMgr:cnn_on_close(cnn, error_num)
    local netid = cnn:netid()
    if 0 ~= error_num then
        log_debug("ClientCnnMgr:cnn_on_close netid:%s error:%s", netid, error_num)
    end
    self.event_proxy:fire(Client_Cnn_Event_Close_Client , netid, error_num)
    self.client_cnns[netid] = nil
end

function ClientCnnMgr:cnn_on_recv(cnn, pid, bin)
    local netid = cnn:netid()
    local client_cnn = self.client_cnns[netid]
    if not client_cnn then
        log_error("ClientCnnMgr:cnn_on_recv not find client %s", netid)
        return
    end
    client_cnn.last_recv_sec = logic_sec()
    local process_fn = self.process_msg_fns[pid]
    if process_fn then
        local is_ok, msg = PROTO_PARSER:decode(pid, bin)
        if is_ok then
            safe_call(process_fn, netid, pid, msg)
        else
            log_error("ClientCnnMgr:cnn_on_recv decode fail pid:%s", pid)
        end
    end
end

function ClientCnnMgr:get_client_cnn(netid)
    return self.client_cnns[netid]
end

function ClientCnnMgr:send(netid, pid, tb)
    local client = self:get_client_cnn(netid)
    if not client then
        return false
    end
    return client:send(pid, tb)
end