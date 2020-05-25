

ClientMgr = ClientMgr or class("ClientMgr", ServiceLogic)

function ClientMgr:ctor(logic_mgr, logic_name)
    ClientMgr.super.ctor(self, logic_mgr, logic_name)
    self.client_cnn_mgr = self.service.client_cnn_mgr
    self.clients = {}
end

function ClientMgr:init()
    ClientMgr.super.init(self)
    self:setup_proto_handler()
end

function ClientMgr:start()
    ClientMgr.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 2 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
    self.event_proxy:subscribe(Client_Cnn_Mgr_Event_New_Client, Functional.make_closure(self._on_new_cnn, self))
    self.event_proxy:subscribe(Client_Cnn_Mgr_Event_Close_Client, Functional.make_closure(self._on_close_cnn, self))
end

function ClientMgr:stop()
    ClientMgr.super.stop(self)
    self.timer_proxy:release_all()
    self.event_proxy:release_all()
end

function ClientMgr:_on_new_cnn(netid, error_code)
    log_debug("ClientMgr:_on_new_cnn %s %s", netid, error_code)
    if 0 ~= error_code then
        return
    end
    local client_cnn = self.client_cnn_mgr:get_client_cnn(netid)
    if client_cnn then
        local client = Client:new(self, netid, client_cnn)
        self.clients[client.netid] = client
    end
end

function ClientMgr:_on_close_cnn(netid, error_code)
    local client = self:get_client(netid)
    if client then
        if client.fight then
            client.fight:unbind_client(client)
        end
        client:release()
    end
    self.clients[netid] = nil
end

function ClientMgr:_on_tick()

end

function ClientMgr:get_client(netid)
    return self.clients[netid]
end

function ClientMgr:send(netid, pid, tb)
    local client = self:get_client(netid)
    if not client then
        return false
    end
    return client:send(pid, tb)
end
