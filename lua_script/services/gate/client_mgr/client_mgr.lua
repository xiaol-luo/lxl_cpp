

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
    log_debug("ClientMgr:_on_new_cnn %s %s", netid, error_code)
    if 0 ~= error_code then
        return
    end
    local client_cnn = self.client_cnn_mgr:get_client_cnn(netid)
    if client_cnn then
        local client = Client:new()
        client.netid = netid
        client.cnn = client_cnn
        client.state = ClientState.Free
        self.clients[client.netid] = client
    end
end

function ClientMgr:_on_close_cnn(netid, error_code)
    log_debug("ClientMgr:_on_close_cnn ")
end

function ClientMgr:_on_tick()

end

function ClientMgr:get_client(netid)
    return self.clients[netid]
end

function ClientMgr:process_req_user_login(netid, pid, msg)
    log_debug("ClientMgr:process_req_user_login %s, %s", netid, msg)
    local error_num = nil
    repeat
        local client = self:get_client(netid)
        if not client then
            error_num = ReqUserLoginError.No_Client
            break
        end
        if ClientState.Free ~= client.state then
            error_num = ReqUserLoginError.State_Not_Fit
            break
        end
        client.state = ClientState.Authing
    until true
    if error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = error_num })
        return
    end

    local over_cb = function(co)
        local ret_vals = co:get_return_vals()
        local error_num = ReqUserLoginError.None
        if not ret_vals then
            error_num = ReqUserLoginError.Coroutine_Error
        else
            error_num = table.unpack(ret_vals.vals, 1, ret_vals.n)
        end
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = error_num })
        if error_num == ReqUserLoginError.None then
            local client = SERVICE_MAIN.client_mgr:get_client(netid)
            client.state = ClientState.Manage_Role
            log_debug("client %s switch state to ClientState.Manage_Role", client.netid)
        end
    end
    local main_logic = function(co, msg)
        local co_ok = nil
        local host = string.format("%s:%s", string.rtrim(msg.auth_ip, "/"), msg.auth_port)
        local query_url = make_http_query_url(host, "gate_auth", {
            token = msg.auth_sn
        })
        log_debug("query_url %s", query_url)
        local id_int64, rsp_state, heads_map, body_str = nil
        co_ok, id_int64, rsp_state, heads_map, body_str = HttpClient.co_get(query_url)
        if not co_ok then
            return ReqUserLoginError.Coroutine_Error
        end
        if not is_rsp_ok(rsp_state) then
            return ReqUserLoginError.Auth_Fail
        end
        local co_get_ret = rapidjson.decode(body_str)
        log_debug("co_get ret %s", co_get_ret)
        if co_get_ret.error_code and #co_get_ret.error_code > 0 then
            return ReqUserLoginError.Auth_Fail
        end


        local world_rpc_client = self.service:create_rpc_client(self.service.zone_name, Service_Const.World, 0)
        print(world_rpc_client:test("123354"))

        return ReqUserLoginError.None
    end
    local co = ex_coroutine_create(main_logic, over_cb)
    local start_ret = ex_coroutine_start(co, co, msg)
    if not start_ret then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = ReqUserLoginError.Start_Auth_Fail })
    end
end

function ClientMgr:process_req_pull_role_digest(netid, pid, msg)
    log_debug("ClientMgr:process_req_pull_role_digest")
end

function ClientMgr:process_req_create_role(netid, pid, msg)

end

function ClientMgr:process_req_launch_role(netid, pid, msg)

end