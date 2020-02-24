
Client_Cnn_Mgr_Event_New_Client = "Client_Cnn_Mgr_Event_New_Client"
Client_Cnn_Mgr_Event_Close_Client = "Client_Cnn_Mgr_Event_Close_Client"

ClientCnnBase = ClientCnnBase or class("ClientCnnBase")

function ClientCnnBase:ctor()
    self.cnn = nil
    self.netid = nil
    self.last_recv_sec = 0
end

function ClientCnnBase:send(pid, tb)
    local is_ok, block = true, nil
    if tb then
        is_ok, block = PROTO_PARSER:encode(pid, tb)
    end
    if not is_ok then
        return false
    end
    return self.cnn:send(pid, block)
end

function ClientCnnBase:send_msg_bytes(pid, msg_bytes)
    return self.cnn:send(pid, msg_bytes)
end

function ClientCnnBase:close()
    if self.cnn then
        self.cnn:reset()
    end
    self.cnn = nil
end

ClientCnnMgrBase = ClientCnnMgrBase or class("ClientCnnMgrBase", ServiceListenModule)

function ClientCnnMgrBase:ctor(module_mgr, module_name)
    ClientCnnMgrBase.super.ctor(self, module_mgr, module_name)
    self.last_check_client_cnn_expired_sec = 0
    self.cnn_tolerate_no_recv_sec = 20
    self.client_cnn_cls = nil
    self.default_process_msg_fn = nil
end

function ClientCnnMgrBase:init(listen_port, cnn_tolerate_no_recv_sec, client_cnn_cls)
    ClientCnnMgrBase.super.init(self, listen_port)
    self.client_cnns = {}
    self.process_msg_fns = {}
    self.cnn_tolerate_no_recv_sec = cnn_tolerate_no_recv_sec
    self.client_cnn_cls = client_cnn_cls or ClientCnnBase
end

function ClientCnnMgrBase:set_process_fn(pid, fn)
    -- fn format function(netid, pid, msg)
    if nil ~= fn then
        assert(not self.process_msg_fns[pid])
    end
    self.process_msg_fns[pid] = fn
end

function ClientCnnMgrBase:set_default_process_fn(fn)
    self.default_process_msg_fn = fn
end

function ClientCnnMgrBase:start()
    ClientCnnMgrBase.super.start(self)
    self.client_cnns = {}
end

function ClientCnnMgrBase:stop()
    ClientCnnMgrBase.super.stop(self)
    for _, v in pairs(self.client_cnns) do
        if v.cnn then
            Net.close(v.cnn:netid())
        end
    end
    self.client_cnns = {}
    self.process_msg_fns = {}
    self.default_process_msg_fn = nil
end

function ClientCnnMgrBase:on_update()
    ClientCnnMgrBase.super.on_update(self)
    local Check_Expired_Span_Sec = 2
    local now_sec = logic_sec()
    if now_sec - self.last_check_client_cnn_expired_sec >= Check_Expired_Span_Sec then
        local expired_netids = {}
        for netid, client_cnn in pairs(self.client_cnns) do
            if now_sec - client_cnn.last_recv_sec >= self.cnn_tolerate_no_recv_sec then
                table.insert(expired_netids, netid)
            end
        end
        for _, netid in ipairs(expired_netids) do
            Net.close(netid)
        end
    end
end

function ClientCnnMgrBase:cnn_on_open(cnn, error_num)
    local netid = cnn:netid()
    if 0 == error_num then
        local client_cnn = self.client_cnn_cls:new()
        client_cnn.cnn = cnn
        client_cnn.netid = cnn:netid()
        client_cnn.last_recv_sec = logic_sec()
        self.client_cnns[netid] = client_cnn
    else
        log_debug("ClientCnnMgrBase:cnn_on_open netid:%s error:%s", netid, error_num)
    end
    self.event_proxy:fire(Client_Cnn_Mgr_Event_New_Client , netid, error_num)
end

function ClientCnnMgrBase:cnn_on_close(cnn, error_num)
    local netid = cnn:netid()
    if 0 ~= error_num then
        log_debug("ClientCnnMgrBase:cnn_on_close netid:%s error:%s", netid, error_num)
    end
    self.event_proxy:fire(Client_Cnn_Mgr_Event_Close_Client , netid, error_num)
    self.client_cnns[netid] = nil
end

function ClientCnnMgrBase:cnn_on_recv(cnn, pid, bin)
    local netid = cnn:netid()
    local client_cnn = self.client_cnns[netid]
    if not client_cnn then
        log_error("ClientCnnMgrBase:cnn_on_recv not find client %s", netid)
        return
    end
    client_cnn.last_recv_sec = logic_sec()
    local process_fn = self.process_msg_fns[pid] or self.default_process_msg_fn
    if process_fn then
        local is_ok, msg = PROTO_PARSER:decode(pid, bin)
        if is_ok then
            safe_call(process_fn, netid, pid, msg)
        else
            log_error("ClientCnnMgrBase:cnn_on_recv decode fail pid:%s", pid)
        end
    else
        log_debug("ClientCnnMgrBase:cnn_on_recv no process fn for pid=%s", pid)
    end
end

function ClientCnnBase:close_cnn(netid)
    local client_cnn = self.client_cnns[netid]
    if client_cnn then
        client_cnn:close()
    end
end

function ClientCnnMgrBase:get_client_cnn(netid)
    return self.client_cnns[netid]
end

function ClientCnnMgrBase:send(netid, pid, tb)
    local client = self:get_client_cnn(netid)
    if not client then
        return false
    end
    return client:send(pid, tb)
end