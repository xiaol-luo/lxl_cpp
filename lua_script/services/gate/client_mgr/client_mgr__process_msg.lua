
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
            client.user_id = msg.user_id
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

        return ReqUserLoginError.None
    end
    local co = ex_coroutine_create(main_logic, over_cb)
    local start_ret = ex_coroutine_start(co, co, msg)
    if not start_ret then
        self.client_cnn_mgr:send(netid, ProtoId.rsp_user_login, { error_num = ReqUserLoginError.Start_Auth_Fail })
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
        if not client then
            error_num = ErrorNum.No_Client
            break
        end
        if client.state <= ClientState.Authing then
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
        local world_rpc_client = self.service:create_rpc_client(world_service.service_key)
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
        if not client then
            error_num = ErrorNum.No_Client
            break
        end
        if client.state <= ClientState.Authing then
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
        local world_rpc_client = self.service:create_rpc_client(world_service.service_key)
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

function ClientMgr:process_req_launch_role(netid, pid, msg)
    log_debug("ClientMgr:process_req_launch_role %s", msg)
    self.client_cnn_mgr:send(netid, ProtoId.rsp_launch_role, { error_num=0 })
end