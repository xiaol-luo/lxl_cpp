
function ClientMgr:setup_proto_handler()
    self.client_cnn_mgr:set_process_fn(ProtoId.req_user_login, Functional.make_closure(self.process_req_user_login, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_pull_role_digest, Functional.make_closure(self.process_req_pull_role_digest, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_create_role, Functional.make_closure(self.process_req_create_role, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_launch_role, Functional.make_closure(self.process_req_launch_role, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_logout_role, Functional.make_closure(self.process_logout_role, self))
    self.client_cnn_mgr:set_process_fn(ProtoId.req_reconnect, Functional.make_closure(self.process_reconnect, self))
end

function ClientMgr:_coro_auth_user_login(auth_ip, auth_port, auth_sn, user_id, app_id, account_id)
    local co_ok = nil
    local host = string.format("%s:%s", string.rtrim(auth_ip, "/"), auth_port)
    local query_url = make_http_query_url(host, "gate_auth", { token = auth_sn })
    log_debug("query_url %s", query_url)
    local http_ret = nil
    co_ok, http_ret = HttpClient.co_get(query_url)
    if not co_ok then
        return Error_Coro_Logic
    end
    local rsp_state, body_str = http_ret.state, http_ret.body
    if not is_rsp_ok(rsp_state) then
        return Error_Http_State
    end
    local co_get_ret = rapidjson.decode(body_str)
    log_debug("co_get ret %s %s %s", co_get_ret, account_id, app_id)
    if co_get_ret.error and #co_get_ret.error > 0 then
        return Error_Exist
    end
    if co_get_ret["uid"] ~= account_id or co_get_ret["appid"] ~= app_id then
        return Error_Exist
    end
    return Error_None
end

function ClientMgr:process_req_user_login(netid, pid, msg)
    log_debug("ClientMgr:process_req_user_login %s, %s", netid, msg)
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client then
            error_num = Error.Gate_User_Login.no_client
            break
        end
        if not client:is_free() then
            error_num = Error.Gate_User_Login.no_client.state_not_fit
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
        local error_num = Error_None
        repeat
            do
                local ret_vals = co:get_return_vals()
                if not ret_vals then
                    error_num = Error_Coro_Logic
                    break
                end
                error_num = table.unpack(ret_vals.vals, 1, ret_vals.n)
                if Error_None ~= error_num then
                    break
                end
                local client = self:get_client(netid)
                if not client or not client:is_authing() then
                    error_num = Error.Gate_User_Login.gate_state_not_fit
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
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = Error.Gate_User_Login.auth_fail })
    end
end

function ClientMgr:process_reconnect(netid, pid, msg)
    log_debug("ClientMgr:process_reconnect %s", msg)
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client then
            error_num = Error.Reconnect_Game.gate_no_client
            break
        end
        if not client:is_free() then
            error_num = Error.Reconnect_Game.gate_client_state_not_fit
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
            return Error.Reconnect_Game.auth_user_fail
        end

        local client = self:get_client(netid)
        if not client or not client:is_authing() then
            return Error.Reconnect_Game.gate_client_state_not_fit
        end
        client.state = ClientState.Manage_Role
        client.user_id = auth_msg.user_id
        client.token = auth_msg.auth_sn

        local world_service_count = self.service.all_service_cfg:get_world_service_count(self.service.zone_name)
        if world_service_count <= 0 then
            return Error.Reconnect_Game.no_valid_world_service
        end
        local service_info = self.service.zone_net:get_service(Service_Const.World, msg.role_id % world_service_count)
        if not service_info or not service_info.net_connected then
            return Error.Reconnect_Game.no_valid_world_service
        end
        client.state = ClientState.Launch_Role
        client.world_client = self.service:create_rpc_client(service_info.key)
        local co_ok, rpc_error_num, logic_error_num, game_key, world_role_session_id = client.world_client:coro_call(
                WorldRpcFn.reconnect_role, client.token, msg.role_id, client.netid)
        log_debug("bind world role callback values: %s %s %s %s %s", co_ok, rpc_error_num, logic_error_num, game_key, world_role_session_id)
        if not co_ok or Error_None ~= rpc_error_num or Error_None ~= logic_error_num then
            return Error.Reconnect_Game.bind_role_fail
        end
        client.state = ClientState.In_Game
        client.launch_role_id = msg.role_id
        client.world_role_session_id = world_role_session_id
        client.game_client = self.service:create_rpc_client(game_key)
        return Error_None
    end

    local over_cb = function(co)
        local error_num = Error_None
        repeat
            do
                local ret_vals = co:get_return_vals()
                if not ret_vals then
                    error_num = Error_Coro_Logic
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
        self.client_cnn_mgr:send(netid, ProtoId.rsp_reconnect, { error_num = Error_Coro_Start })
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
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client or not client:is_alive() then
            error_num = Error.Pull_Role_Digest.no_client
            break
        end
        if not client:is_authed() then
            error_num = Error.Pull_Role_Digest.need_auth
            break
        end
        if not client.user_id then
           error_num = Error_Unknown
            break
        end
        local world_service = self.service.zone_net:rand_service(Service_Const.World)
        if not world_service then
            error_num = Error.Pull_Role_Digest.no_valid_world_service
            break
        end
        local world_rpc_client = self.service:create_rpc_client(world_service.key)
        world_rpc_client:call(function(rpc_error_num, role_digests, ...)
            local msg_error_num = ErrorNum.None
            local msg_role_digests = nil
            if Rpc_Error.None ~= rpc_error_num then
                msg_error_num = Error.Pull_Role_Digest.query_fail
            else
                msg_role_digests = role_digests
            end
            log_debug("process_req_pull_role_digest rpc result %s", msg_role_digests)
            self.client_cnn_mgr:send(netid, ProtoId.rsp_pull_role_digest, { error_num=msg_error_num, role_digests=msg_role_digests })
        end, WorldRpcFn.get_role_digest, client.user_id, msg.role_id)
    until true
    if ErrorNum.None ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_pull_role_digest, { error_num = error_num })
    end
end

function ClientMgr:process_req_create_role(netid, pid, msg)
    log_debug("ClientMgr:process_req_create_role %s %s %s", netid, pid, msg)
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client or not client:is_alive() then
            error_num = Error.Create_Role.no_client
            break
        end
        if not client:is_authed() then
            error_num = Error.Create_Role.need_auth
            break
        end
        if not client.user_id then
            error_num = Error_Unknown
            break
        end
        local world_service = self.service.zone_net:rand_service(Service_Const.World)
        if not world_service then
            error_num = Error.Create_Role.no_valid_world_service
            break
        end
        local world_rpc_client = self.service:create_rpc_client(world_service.key)
        world_rpc_client:call(function(rpc_error_num, new_role_id, ...)
            local msg_error_num = ErrorNum.None
            local msg_role_id = nil
            if Rpc_Error.None ~= rpc_error_num then
                msg_error_num = Error.Create_Role.query_fail
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

function ClientMgr:process_req_launch_role(netid, pid, msg)
    log_debug("ClientMgr:process_req_launch_role %s", msg)

    local error_num = Error_None
    repeat
    do
        local client = self:get_client(netid)
        if not client or ClientState.Manage_Role ~= client.state or not client.user_id then
            error_num = Error.Launch_Role.state_not_fit
            break
        end
        local world_service_count = self.service.all_service_cfg:get_world_service_count(self.service.zone_name)
        if world_service_count <= 0 then
            error_num = Error.Launch_Role.no_valid_world_service
            break
        end
        local service_info = self.service.zone_net:get_service(Service_Const.World, msg.role_id % world_service_count)
        if not service_info or not service_info.net_connected then
            error_num = Error.Launch_Role.no_valid_world_service
            break
        end
        local world_rpc_client = self.service:create_rpc_client(service_info.key)
        client.state = ClientState.Launch_Role
        client.world_client = world_rpc_client
        world_rpc_client:call(Functional.make_closure(self._rpc_rsp_req_luanch_role, self, netid, msg.role_id),
                WorldRpcFn.launch_role, msg.role_id, netid, client.token)
    end
    until true
    if Error_None ~= error_num then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_launch_role, { error_num = error_num })
    end
end

function ClientMgr:_rpc_rsp_req_luanch_role(netid, role_id, rpc_error_num, launch_error_num, game_key, world_role_session_id, ...)
    local error_num = Error_None
    repeat
    do
        if Error_None ~= rpc_error_num then
            error_num = rpc_error_num
            break
        end
        if Error_None ~= launch_error_num then
            error_num = launch_error_num
            break
        end
        local client = self:get_client(netid)
        if not client or ClientState.Launch_Role ~= client.state then
            error_num = Error.Launch_Role.state_not_fit
            break
        end
        client.state = ClientState.In_Game
        client.launch_role_id = role_id
        client.world_role_session_id = world_role_session_id
        client.game_client = self.service:create_rpc_client(game_key)
        log_debug("process_req_launch_role rpc success role_id:%s", client.launch_role_id)
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

function ClientMgr:process_logout_role(netid, pid, msg)
    log_debug("ClientMgr:process_logout_role 1")
    local error_num = Error_None
    repeat
        local client = self:get_client(netid)
        if not client then
            error_num = Error_Unknown
            break
        end
        if ClientState.In_Game ~= client.state or not client.launch_role_id or msg.role_id ~= client.launch_role_id then
            error_num = Error.Logout_Role.not_launch_role
            break
        end
        client.world_client:call(Functional.make_closure(self._rpc_rsp_logout_role, self, netid),
            WorldRpcFn.logout_role, client.world_role_session_id, client.launch_role_id)
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
            error_num = rpc_error_num
            break
        end
        if Error_None ~= logout_error_num then
            error_num = logout_error_num
            break
        end
        if ClientState.In_Game ~= client.state then
            error_num = Error.Logout_Role.state_not_fit
            break
        end
        client.state = ClientState.Manage_Role
        client.role_id = nil
        client.world_client = nil
        client.world_role_session_id = nil
    until true
    log_debug("ClientMgr:process_logout_role 3 %s", error_num)
    self.client_cnn_mgr:send(netid, ProtoId.rsp_logout_role, { error_num = error_num })
end
