
function ClientMgr:setup_proto_handler()
    self.client_cnn_mgr:set_process_fn(ProtoId.req_user_login, Functional.make_closure(self.process_req_user_login, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_pull_role_digest, Functional.make_closure(self.process_req_pull_role_digest, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_create_role, Functional.make_closure(self.process_req_create_role, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_launch_role, Functional.make_closure(self.process_req_launch_role, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_logout_role, Functional.make_closure(self.process_logout_role, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_reconnect, Functional.make_closure(self.process_reconnect, self))
end


_Req_User_Login_Error = {
    None = 0,
    No_Client = 1,
    State_Not_Fit = 2,
    Start_Auth_Fail = 3,
    Auth_Fail = 4,
    Coroutine_Error = 5,
}

function ClientMgr:_coro_auth_user_login(auth_ip, auth_port, auth_sn, user_id, app_id, account_id)
    local co_ok = nil
    local host = string.format("%s:%s", string.rtrim(auth_ip, "/"), auth_port)
    local query_url = make_http_query_url(host, "gate_auth", { token = auth_sn })
    log_debug("query_url %s", query_url)
    local http_ret = nil
    co_ok, http_ret = HttpClient.co_get(query_url)
    if not co_ok then
        return _Req_User_Login_Error.Coroutine_Error
    end
    local rsp_state, body_str = http_ret.state, http_ret.body
    if not is_rsp_ok(rsp_state) then
        return _Req_User_Login_Error.Auth_Fail
    end
    local co_get_ret = rapidjson.decode(body_str)
    log_debug("co_get ret %s %s %s", co_get_ret, account_id, app_id)
    if co_get_ret.error and #co_get_ret.error > 0 then
        return _Req_User_Login_Error.Auth_Fail
    end
    if co_get_ret["uid"] ~= account_id or co_get_ret["appid"] ~= app_id then
        return _Req_User_Login_Error.Auth_Fail
    end
    return Error_None
end

function ClientMgr:process_req_user_login(netid, pid, msg)
    log_debug("ClientMgr:process_req_user_login %s, %s", netid, msg)
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client then
            error_num = _Req_User_Login_Error.No_Client
            break
        end
        if not client:is_free() then
            error_num = _Req_User_Login_Error.State_Not_Fit
            break
        end
        client.state = ClientState.Authing
    until true
    if Error_None ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = error_num })
        return
    end

    local main_logic = function(co, msg)
        return self:_coro_auth_user_login(msg.auth_ip, msg.auth_port, msg.auth_sn, msg.user_id, msg.app_id, msg.account_id)
    end

    local over_cb = function(co)
        local error_num = _Req_User_Login_Error.None
        repeat
            do
                local ret_vals = co:get_return_vals()
                if not ret_vals then
                    error_num = _Req_User_Login_Error.Coroutine_Error
                    break
                end
                error_num = table.unpack(ret_vals.vals, 1, ret_vals.n)
                if Error_None ~= error_num then
                    break
                end
                local client = self:get_client(netid)
                if not client or not client:is_authing() then
                    error_num = _Req_User_Login_Error.State_Not_Fit
                    break
                end
                client.state = ClientState.Manage_Role
                client.user_id = msg.user_id
                client.token = msg.auth_sn
            end
        until true
        if Error_None ~= error_num then
            local client = self:get_client(netid)
            if client then
                if ClientState.Authing == client.state then
                    client.state = ClientState.Free
                end
            end
        end
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = error_num })
    end

    local co = ex_coroutine_create(main_logic, over_cb)
    local start_ret = ex_coroutine_start(co, co, msg)
    if not start_ret then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = _Req_User_Login_Error.Start_Auth_Fail })
    end
end

_Error_Reconnect =
{
    start_logic_fail = 1,
    auth_user_fail = 2,
    coroutine_raise_error = 3,
    state_not_fit = 4,
    no_client = 5,
    no_valid_world_service = 6,
    bind_role_fail = 7,
}

function ClientMgr:process_reconnect(netid, pid, msg)
    log_debug("ClientMgr:process_reconnect %s", msg)
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client then
            error_num = _Error_Reconnect.no_client
            break
        end
        if not client:is_free() then
            error_num = _Error_Reconnect.state_not_fit
            break
        end
        client.state = ClientState.Authing
    until true
    if Error_None ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_reconnect, { error_num = error_num })
        return
    end

    local main_logic = function(co, msg)
        local auth_msg = msg.user_login_msg
        local auth_error_num = self:_coro_auth_user_login(auth_msg.auth_ip,
                auth_msg.auth_port, auth_msg.auth_sn, auth_msg.user_id, auth_msg.app_id, auth_msg.account_id)
        if Error_None ~= auth_error_num then
            return _Error_Reconnect.auth_error_num
        end

        local client = SERVICE_MAIN.client_mgr:get_client(netid)
        if not client or not client:is_authing() then
            return _Error_Reconnect.state_not_fit
        end
        client.state = ClientState.Manage_Role
        client.user_id = auth_msg.user_id
        client.token = auth_msg.auth_sn

        local service_info = self.service.zone_net:get_service(Service_Const.World, msg.role_id % WORLD_SERVICE_NUM)
        if not service_info or not service_info.net_connected then
            return _Error_Reconnect.no_valid_world_service
        end
        local world_rpc_client = self.service:create_rpc_client(service_info.key)
        client.state = ClientState.Launch_Role
        client.world_client = world_rpc_client
        local co_ok, rpc_error_num, logic_error_num, game_key, world_session_id = world_rpc_client:coro_call(WorldRpcFn.reconnect_role, client.token, msg.role_id)
        -- log_debug("bind world role callback values: %s %s %s %s %s", co_ok, rpc_error_num, logic_error_num, game_key, world_session_id)
        if not co_ok or Error_None ~= logic_error_num then
            return _Error_Reconnect.bind_role_fail
        end
        client.state = ClientState.In_Game
        client.launch_role_id = msg.role_id
        client.world_session_id = world_session_id
        client.game_client = self.service:create_rpc_client(game_key)
        return Error_None
    end

    local over_cb = function(co)
        local error_num = Error_None
        repeat
            do
                local ret_vals = co:get_return_vals()
                if not ret_vals then
                    error_num = _Error_Reconnect.coroutine_raise_error
                    break
                end
                error_num = table.unpack(ret_vals.vals, 1, ret_vals.n)
                if Error_None ~= error_num then
                    break
                end
            end
        until true
        if Error_None ~= error_num then
            local client = self:get_client(netid)
            if client then
                if ClientState.Authing == client.state then
                    client.state = ClientState.Free
                end
                if ClientState.Launch_Role == client.state then
                    client.state = ClientState.Manage_Role
                end
            end
        end
        log_debug("ClientMgr:process_reconnect over_cb error_num %s", error_num)
        self.client_cnn_mgr:send(netid, ProtoId.rsp_reconnect, { error_num = error_num })
    end

    local co = ex_coroutine_create(main_logic, over_cb)
    local start_ret = ex_coroutine_start(co, co, msg)
    if not start_ret then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_reconnect, { error_num = _Error_Reconnect.start_logic_fail })
    end
end


local ErrorNum = {
    None = 0,
    No_Client = 1,
    No_WORLD_SERVICE = 2,
    Need_Auth = 3,
    Query_Fail = 4,
    Unknown = 5,
}

function ClientMgr:process_req_pull_role_digest(netid, pid, msg)
    log_debug("ClientMgr:process_req_pull_role_digest %s", msg)
    local error_num = ErrorNum.None
    repeat
        local client = self:get_client(netid)
        if not client or not client:is_alive() then
            error_num = ErrorNum.No_Client
            break
        end
        if not client:is_authed() then
            error_num = ErrorNum.Need_Auth
            break
        end
        if not client.user_id then
           error_num = ErrorNum.Unknown
            break
        end
        local world_service = self.service.zone_net:rand_service(Service_Const.World)
        if not world_service or not world_service.net_connected then
            error_num = ErrorNum.No_WORLD_SERVICE
            break
        end
        local world_rpc_client = self.service:create_rpc_client(world_service.key)
        world_rpc_client:call(function(rpc_error_num, role_digests, ...)
            local msg_error_num = ErrorNum.None
            local msg_role_digests = nil
            if Rpc_Error.None ~= rpc_error_num then
                msg_error_num = ErrorNum.Query_Fail
            else
                msg_role_digests = role_digests
            end
            log_debug("process_req_pull_role_digest rpc result %s", msg_role_digests)
            self.client_cnn_mgr:send(netid, ProtoId.rsp_pull_role_digest, { error_num=msg_error_num, role_digests=msg_role_digests })
        end, WorldRpcFn.get_role_digest, client.user_id, msg.role_id)
    until true
    if ErrorNum.None ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_pull_role_digest, { error_num=error_num })
    end
end

function ClientMgr:process_req_create_role(netid, pid, msg)
    log_debug("ClientMgr:process_req_create_role %s %s %s", netid, pid, msg)
    local error_num = ErrorNum.None
    repeat
        local client = self:get_client(netid)
        if not client or not client:is_alive() then
            error_num = ErrorNum.No_Client
            break
        end
        if not client:is_authed() then
            error_num = ErrorNum.Need_Auth
            break
        end
        if not client.user_id then
            error_num = ErrorNum.Unknown
            break
        end
        local world_service = self.service.zone_net:rand_service(Service_Const.World)
        if not world_service then
            error_num = ErrorNum.No_WORLD_SERVICE
            break
        end
        local world_rpc_client = self.service:create_rpc_client(world_service.key)
        world_rpc_client:call(function(rpc_error_num, new_role_id, ...)
            local msg_error_num = ErrorNum.None
            local msg_role_id = nil
            if Rpc_Error.None ~= rpc_error_num then
                msg_error_num = ErrorNum.Query_Fail
            else
                msg_role_id = new_role_id
            end
            self.client_cnn_mgr:send(netid, ProtoId.rsp_create_role, { error_num=msg_error_num, role_id=msg_role_id })
        end, WorldRpcFn.create_role, client.user_id)
    until true
    if ErrorNum.None ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_create_role, { error_num=error_num })
    end
end

_Process_Launch_Role_Error = {
    none = 0,
    no_valid_world_service = 1,
    rpc_error = 2,
    launch_fail = 3,
    state_error = 4,
}
function ClientMgr:process_req_launch_role(netid, pid, msg)
    log_debug("ClientMgr:process_req_launch_role %s", msg)

    local error_num = _Process_Launch_Role_Error.none
    repeat
    do
        local client = self:get_client(netid)
        if not client or ClientState.Manage_Role ~= client.state or not client.user_id then
            error_num = _Process_Launch_Role_Error.state_error
            break
        end
        local service_info = self.service.zone_net:get_service(Service_Const.World, msg.role_id % WORLD_SERVICE_NUM)
        if not service_info or not service_info.net_connected then
            error_num = _Process_Launch_Role_Error.no_valid_world_service
            break
        end
        local world_rpc_client = self.service:create_rpc_client(service_info.key)
        client.state = ClientState.Launch_Role
        client.world_client = world_rpc_client
        world_rpc_client:call(Functional.make_closure(self._rpc_rsp_req_luanch_role, self, netid, msg.role_id),
                WorldRpcFn.launch_role, msg.role_id, netid, client.token)
    end
    until true
    if _Process_Launch_Role_Error.none ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_launch_role, { error_num = error_num })
    end
end

function ClientMgr:_rpc_rsp_req_luanch_role(netid, role_id, rpc_error_num, launch_error_num, game_key, world_session_id, ...)
    local error_num = _Process_Launch_Role_Error.none
    repeat
    do
        if Rpc_Error.None ~= rpc_error_num then
            error_num = _Process_Launch_Role_Error.rpc_error
            break
        end
        if Error_None ~= launch_error_num then
            error_num = _Process_Launch_Role_Error.launch_fail
            break
        end
        local client = self:get_client(netid)
        if not client or ClientState.Launch_Role ~= client.state then
            error_num = _Process_Launch_Role_Error.state_error
            break
        end
        client.state = ClientState.In_Game
        client.launch_role_id = role_id
        client.world_session_id = world_session_id
        client.game_client = self.service:create_rpc_client(game_key)
        log_debug("process_req_launch_role rpc success client:%s", client)
    end
    until true
    if Error_None ~= error_num then
        local client = self:get_client(netid)
        if client then
            if ClientState.Launch_Role == client.state then
                client.state = ClientState.Manage_Role
            end
        end
    end
    self.client_cnn_mgr:send(netid, ProtoId.rsp_launch_role, { error_num = error_num })
    log_debug("process_req_launch_role rpc game_key:%s error_num:%s, launch_error_num:%s", game_key, error_num, launch_error_num)
end

_Logout_Role_Error = {
    unknown = 1,
    not_launch_role = 2,
    logout_fail = 3,
    rpc_fail = 4,
    state_invalid = 5,
}

function ClientMgr:process_logout_role(netid, pid, msg)
    log_debug("ClientMgr:process_logout_role 1")
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client then
            error_num = _Logout_Role_Error.unknown
            break
        end
        if ClientState.In_Game ~= client.state or not client.launch_role_id or msg.role_id ~= client.launch_role_id then
            error_num = _Logout_Role_Error.not_launch_role
            break
        end
        client.world_client:call(Functional.make_closure(self._rpc_rsp_logout_role, self, netid),
            WorldRpcFn.logout_role, client.world_session_id, client.launch_role_id)
    until true
    log_debug("ClientMgr:process_logout_role 2 %s", error_num)
    if Error_None ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_logout_role, { error_num = error_num})
    end
end

function ClientMgr:_rpc_rsp_logout_role(netid, rpc_error_num, logout_error_num)
    local client = self:get_client(netid)
    if not client then
        return
    end
    local error_num = Error_None
    repeat
        if Error_None ~= rpc_error_num then
            error_num = _Logout_Role_Error.rpc_fail
            break
        end
        if Error_None ~= logout_error_num then
            error_num = _Logout_Role_Error.logout_fail
            break
        end
        if ClientState.In_Game ~= client.state then
            error_num = _Logout_Role_Error.state_invalid
            break
        end
        client.state = ClientState.Manage_Role
        client.role_id = nil
        client.world_client = nil
        client.world_session_id = nil
    until true
    log_debug("ClientMgr:process_logout_role 3 %s, client:%s", error_num, client)
    self.client_cnn_mgr:send(netid, ProtoId.rsp_logout_role, { error_num = error_num })
end
