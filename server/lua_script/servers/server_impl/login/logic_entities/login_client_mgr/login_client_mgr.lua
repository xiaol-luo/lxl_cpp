
---@class LoginClientMgr:GameLogicEntity
---@field server loginServer
LoginClientMgr = LoginClientMgr or class("LoginClientMgr", LogicEntityBase)

function LoginClientMgr:ctor(logics, logic_name)
    LoginClientMgr.super.ctor(self, logics, logic_name)
    ---@type table<number, LoginClient>
    self._login_clients = {}
    ---@type ClientNetService
    self._client_net_svc = self.server.client_net
    self._msg_handlers = {}
    ---@type ProtoParser
    self._pto_parser = self.server.pto_parser
end

function LoginClientMgr:_on_init()
    LoginClientMgr.super._on_init(self)
    -- self:setup_proto_handler()

    ---@type ClientNetServiceCnnCallback
    local cnn_cbs = {}
    cnn_cbs.on_open = Functional.make_closure(self._client_net_svc_cnn_on_open, self)
    cnn_cbs.on_close = Functional.make_closure(self._client_net_svc_cnn_on_close, self)
    cnn_cbs.on_recv = Functional.make_closure(self._client_net_svc_cnn_on_recv, self)
    self._client_net_svc:set_cnn_cbs(cnn_cbs)
end

function LoginClientMgr:_on_start()
    LoginClientMgr.super._on_start(self)

    local Tick_Span_Ms = 2 * 1000
    self._timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
end

function LoginClientMgr:_on_stop()
    LoginClientMgr.super._on_stop(self)
    self._timer_proxy:release_all()
end

function LoginClientMgr:_on_release()
    LoginClientMgr.super._on_release(self)
end

function LoginClientMgr:_on_update()
    LoginClientMgr.super._on_update(self)
end

---@param client_net_svc ClientNetService
function LoginClientMgr:_client_net_svc_cnn_on_open(client_net_svc, netid)
    local cnn = client_net_svc:get_cnn(netid)
    if not cnn then
        return
    end

    if self._login_clients[netid] then
        log_error("LoginClientMgr:_client_net_svc_cnn_on_open unknown error: repeated netid %s", netid)
        Net.close(netid)
        return
    end

    local login_client = LoginClient:new(cnn)
    self._login_clients[netid] = login_client
end

function LoginClientMgr:_client_net_svc_cnn_on_close(client_net_svc, netid, error_code)
    local login_client = self._login_clients[netid]
    if not login_client then
        return
    end
    self._login_clients[netid] = nil
end

function LoginClientMgr:_client_net_svc_cnn_on_recv(client_net_svc, netid, pid, bin)
    local handle_fn = self._msg_handlers[pid]
    if not handle_fn then
        log_warn("LoginClientMgr:_client_net_svc_cnn_on_recv not set handle function for pid %s", pid)
        return
    end

    local login_client = self._login_clients[netid]
    if not login_client then
        local cnn = client_net_svc:get_cnn(netid)
        if cnn then
            Net.close(netid)
        end
        return
    end

    local is_ok, msg = true, nil
    if self._pto_parser:exist(pid) then
        is_ok, msg = self._pto_parser:decode(pid, bin)
    end
    if is_ok then
        handle_fn(login_client, pid, msg)
    end
end

function LoginClientMgr:_on_tick()

end

function LoginClientMgr:get_client(netid)
    return self._login_clients[netid]
end

function LoginClientMgr:set_msg_handler(pid, handler)
    if handler then
        assert(is_function(handler))
        assert(not self._msg_handlers[pid])
    end
    self._msg_handlers[pid] = handler
end
