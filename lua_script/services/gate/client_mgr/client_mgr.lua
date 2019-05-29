

ClientMgr = ClientMgr or class("ClientMgr", ServiceLogic)

function ClientMgr:ctor(logic_mgr, logic_name)
    ClientMgr.super.ctor(self, logic_mgr, logic_name)
    self.client_cnn_mgr = self.service.client_cnn_mgr
    self.clients = {}
end

function ClientMgr:init()
    ClientMgr.super.init(self)
    self.timer_proxy = TimerProxy:new()
    self.client_cnn_mgr:set_process_fn(ProtoId.req_user_login, Functional.make_closure(self.process_req_user_login, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_pull_role_digest, Functional.make_closure(self.process_req_pull_role_digest, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_create_role, Functional.make_closure(self.process_req_create_role, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_launch_role, Functional.make_closure(self.process_req_launch_role, self))
end

function ClientMgr:start()
    ClientMgr.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 2 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
    self.event_proxy:subscribe(Client_Cnn_Event_New_Client, Functional.make_closure(self._on_new_cnn, self))
    self.event_proxy:subscribe(Client_Cnn_Event_Close_Client, Functional.make_closure(self._on_close_cnn, self))
end

function ClientMgr:stop()
    ClientMgr.super.stop(self)
    self.timer_proxy:release_all()
    self.event_proxy:release_all()
end

function ClientMgr:_on_new_cnn(netid, error_code)
    log_debug("ClientMgr:_on_new_cnn ")
    local client_cnn = self.client_cnn_mgr:get_client_cnn(netid)
    if client_cnn then
        local client = Client:new()
        client.cnn = client_cnn
    end
end

function ClientMgr:_on_close_cnn(netid, error_code)
    log_debug("ClientMgr:_on_close_cnn ")
end

function ClientMgr:_on_tick()

end

function ClientMgr:process_req_user_login(netid, pid, msg)

end

function ClientMgr:process_req_pull_role_digest(netid, pid, msg)

end

function ClientMgr:process_req_create_role(netid, pid, msg)

end

function ClientMgr:process_req_launch_role(netid, pid, msg)

end