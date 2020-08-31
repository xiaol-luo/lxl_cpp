
function send_msg(cnn, pid, tb)
    local is_ok, block = true, nil
    if PROTO_PARSER:exist(pid) then
        is_ok, block = PROTO_PARSER:encode(pid, tb)
        if not is_ok then
            return false
        end
    end
    return cnn:send(pid, block)
end

LoginAction = LoginAction or class("LoginAction", ServiceLogic)

function LoginAction:ctor(logic_mgr, logic_name)
    LoginAction.super.ctor(self, logic_mgr, logic_name)
    self.timer_proxy = nil
    self.cnn = nil
    self.co = nil
end

function LoginAction:init()
    LoginAction.super.init(self)
end

function LoginAction:start()
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 5 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)

    self.co = ex_coroutine_create(
            Functional.make_closure(self.robot_main_logic, self),
            Functional.make_closure(self.robot_over_logic, self)
    )
    ex_coroutine_expired(self.co, 60 * 1000)
    local is_ok, msg = ex_coroutine_start(self.co, self.co)
    log_debug("start robot main logic ret:%s", is_ok)
    if not is_ok then
        self.error_num = 1
        self.error_msg = "start logic faifl"
    else
        LoginAction.super.start(self)
    end
end

function LoginAction:stop()
    LoginAction.super.stop(self)
    self.timer_proxy:release_all()
end

function LoginAction:_on_tick()
    if not self.co or CoroutineState.Dead == ex_coroutine_status(self.co) then
        self.co = ex_coroutine_create(
                Functional.make_closure(self.robot_main_logic, self),
                Functional.make_closure(self.robot_over_logic, self)
        )
        ex_coroutine_start(self.co, self.co)
        ex_coroutine_expired(self.co, 60 * 1000)
        log_debug("main logic one more time +++++++++++++++++++++++++++++++++++++++")
    else
        -- log_debug("LoginAction:_on_tick %s, memory used %s", self.co and ex_coroutine_status(self.co) or "co null", collectgarbage("count"))
    end
end

function LoginAction:on_cnn_recv(cnn, pid, block)
    if self.cnn ~= cnn then
        return
    end
    local is_ok, msg = PROTO_PARSER:decode(pid, block)
    if is_ok then
        if self.co then
            ex_coroutine_delay_resume(self.co, pid, msg)
        end
    end
    log_debug("LoginAction:on_cnn_recv %s %s", pid, msg)
end

_LoginAction_Const = {
    cb_new_cnn = "cb_new_cnn",
    cb_close_cnn = "cb_close_cnn",
}

function LoginAction:_on_new_cnn(cnn, error_code)
    log_debug("LoginAction:_on_new_cnn, error_code:%s", error_code)
    if Error_None ~= error_code then
        if self.cnn and self.cnn == cnn and self.co then
            ex_coroutine_kill(self.co, "connection is open fail")
        end
    else
        if self.co then
            ex_coroutine_delay_resume(self.co, _LoginAction_Const.cb_new_cnn, error_code)
        end
    end
end

function LoginAction:_on_close_cnn(cnn, error_code)
    if self.cnn and self.cnn == cnn and self.co then
        ex_coroutine_kill(self.co, "connection is close unexpected")
    end
end

function LoginAction:robot_over_logic(co)
    log_debug("LoginAction:robot_over_logic reach")
    self.co = nil
    if self.cnn then
        Net.close(self.cnn:netid())
    end
    self.cnn = nil
    if not co:get_return_vals() then
        log_debug("LoginAction:robot_over_logic %s", co:get_error_msg())
    end
end

function LoginAction:robot_main_logic(co)
    log_debug("LoginAction:robot_main_logic 1")
    -- platform service
    local user_name = "lxl_zz_11"
    if true then
        user_name = string.format("%s_%s_%s", self.logic_name, logic_ms(), native.gen_uuid())
    end
    local co_ok = true
    local login_params = {
        appid="for_test",
        username = user_name,
        pwd = "pwd",
    }
    local login_param_strs = {}
    for k, v in pairs(login_params) do
        table.insert(login_param_strs, string.format("%s=%s", k, v))
    end
    local platform_cfg_group = self.service.all_service_cfg:get_third_party_service_group(Service_Const.Platform_Service, self.logic_mgr.service.zone_name)
    local _, platform_cfg = random.pick_one(platform_cfg_group)
    local host = string.format("%s:%s", platform_cfg[Service_Const.Ip], platform_cfg[Service_Const.Port])
    local url = string.format("%s/%s?%s", host, "login", table.concat(login_param_strs, "&"))
    log_debug("url = %s", url)
    ---@type HttpClientRspResult
    local http_ret = nil
    co_ok, http_ret = HttpClient.co_get(url, {})
    if not co_ok then
        return
    end
    if Error_None ~= http_ret.error_num then
        return
    end
    local platform_login_ret = rapidjson.decode(http_ret.body)

    -- login service
    local cnn = PidBinCnn:new()
    self.cnn = cnn
    cnn:set_recv_cb(Functional.make_closure(self.on_cnn_recv, self))
    cnn:set_open_cb(Functional.make_closure(self._on_new_cnn, self))
    cnn:set_close_cb(Functional.make_closure(self._on_close_cnn, self))

    local login_cfg_group = self.service.all_service_cfg:get_game_service_group(self.service.zone_name, Service_Const.Login)
    local _, login_cfg = random.pick_one(login_cfg_group)
    Net.connect_async(login_cfg[Service_Const.Ip], login_cfg[Service_Const.Client_Port], cnn)

    log_debug("LoginAction:robot_main_logic 1")
    local cb_type, cb_error_num = nil
    co_ok, cb_type, cb_error_num = ex_coroutine_yield(co)
    if not co_ok or Error_None ~= cb_error_num then
        log_debug("LoginAction:robot_main_logic 2, %s %s", co_ok, cb_error_num)
        return
    end
    log_debug("LoginAction:robot_main_logic 3")

    send_msg(cnn, ProtoId.req_login_game, {
        token = platform_login_ret["token"],
        timestamp = platform_login_ret["timestamp"],
        platform = "",
    })
    local pid, msg = nil, nil
    co_ok, pid, msg = ex_coroutine_yield(co)
    if not co_ok then
        return
    end
    log_debug("LoginAction:robot_main_logic pid:%s msg:%s", pid, msg)
    self.cnn = nil
    Net.close(cnn:netid())

    -- gate service
    cnn = PidBinCnn:new()
    self.cnn = cnn
    cnn:set_recv_cb(Functional.make_closure(self.on_cnn_recv, self))
    cnn:set_open_cb(Functional.make_closure(self._on_new_cnn, self))
    cnn:set_close_cb(Functional.make_closure(self._on_close_cnn, self))
    Net.connect_async(msg.gate_ip, msg.gate_port, cnn)
    local cnn_error_code = 0
    co_ok, cb_type, cnn_error_code = ex_coroutine_yield(co)
    if not co_ok and 0 ~= cnn_error_code then
        return
    end
    log_debug("to comunicate with gate")

    local gate_ip = msg.gate_ip
    local gate_port = msg.gate_port
    local login_gate_data = {
        user_id = msg.user_id,
        app_id = msg.app_id,
        auth_sn = msg.auth_sn,
        auth_ip = msg.auth_ip,
        auth_port = msg.auth_port,
        account_id = msg.account_id,
    }

    send_msg(cnn, ProtoId.req_user_login, login_gate_data)
    co_ok, pid, msg = ex_coroutine_yield(co)
    if not co_ok then
        return
    end
    log_debug("req_user_login  pid:%s msg:%s", pid, msg)
    if 0 ~= msg.error_num then
        return
    end
    local role_ids = {}
    send_msg(cnn, ProtoId.req_pull_role_digest, {
        role_id = nil,
    })
    co_ok, pid, msg = ex_coroutine_yield(co)
    if  not co_ok then
        return
    end
    log_debug("req_pull_role_digest msg:%s", msg)
    if msg.role_digests then
        for _, role_digest in pairs(msg.role_digests) do
            table.insert(role_ids, role_digest.role_id)
        end
    end
    send_msg(cnn, ProtoId.req_create_role, {
        params = nil
    })
    co_ok, pid, msg = ex_coroutine_yield(co)
    if not co_ok then
        return
    end
    log_debug("req_create_role msg:%s", msg)
    if 0 == msg.error_num then
        send_msg(cnn, ProtoId.req_pull_role_digest, {
            role_id = msg.role_id,
        })
        co_ok, pid, msg = ex_coroutine_yield(co)
        if not co_ok then
            return
        end
        log_debug("req_pull_role_digest after crete role msg:%s", msg)
        if msg.role_digests then
            for _, role_digest in pairs(msg.role_digests) do
                table.insert(role_ids, role_digest.role_id)
            end
        end
    end
    if #role_ids <= 0 then
        log_debug("not role to launch")
        return
    end

    log_debug("try to req_lanch_role, now has role %s", role_ids)
    send_msg(cnn, ProtoId.req_launch_role, {
        role_id = role_ids[1]
    })
    co_ok, pid, msg = ex_coroutine_yield(co)
    log_debug("req_launch_role:%s", msg)
    if not co then
        return
    end

    self.cnn = nil
    Net.close(cnn:netid())

    -- gate service to reconnect
    cnn = PidBinCnn:new()
    self.cnn = cnn
    cnn:set_recv_cb(Functional.make_closure(self.on_cnn_recv, self))
    cnn:set_open_cb(Functional.make_closure(self._on_new_cnn, self))
    cnn:set_close_cb(Functional.make_closure(self._on_close_cnn, self))
    Net.connect_async(gate_ip, gate_port, cnn)
    co_ok, cb_type, cnn_error_code = ex_coroutine_yield(co)
    if not co_ok and 0 ~= cnn_error_code then
        return
    end
    log_debug("to comunicate with gate for reconnect")

    send_msg(cnn, ProtoId.req_reconnect, {
        login_gate_data = login_gate_data,
        role_id = role_ids[1],
    })
    co_ok, pid, msg = ex_coroutine_yield(co)

    local pto_id = ProtoId.req_join_match
    local is_ok, proto_bytes = PROTO_PARSER:encode(pto_id, {
        match_type = Match_Type.balance,
    })
    send_msg(cnn, ProtoId.req_client_forward_game, {
        pto_id = pto_id,
        proto_bytes = proto_bytes,
    })
    co_ok, pid, msg = ex_coroutine_yield(co)
    log_debug("req_client_forward_game result is pid:%s, msg:%s", pid, msg)

    repeat
        co_ok, pid, msg = ex_coroutine_yield(co)
        if pid == ProtoId.notify_terminate_room then
            break
        end
        if pid == ProtoId.sync_room_state then
            if msg.state == 3 then
                send_msg(cnn, ProtoId.req_client_forward_game, {
                    pto_id = ProtoId.pull_remote_room_state,
                    proto_bytes = nil,
                })
                co_ok, pid, msg = ex_coroutine_yield(co)
                log_debug("in loop for match ! %s %s", pid, msg)
            end
        end
    until false

    send_msg(cnn, ProtoId.req_logout_role, {
        role_id = role_ids[1]
    })
    co_ok, pid, msg = ex_coroutine_yield(co)

    self.cnn = nil
    Net.close(cnn:netid())

    log_debug("robot run complete successfully!!!")
end
