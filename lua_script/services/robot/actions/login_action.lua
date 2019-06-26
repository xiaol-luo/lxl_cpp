
function send_msg(cnn, pid, tb)
    local is_ok, block = PROTO_PARSER:encode(pid, tb)
    if not is_ok then
        return false
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
    self.timer_proxy = TimerProxy:new()
end

function LoginAction:start()
    LoginAction.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 1 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
    self.cnn = PidBinCnn:new()
    self.cnn:set_recv_cb(Functional.make_closure(self.on_cnn_recv, self))
    self.cnn:set_open_cb(Functional.make_closure(self._on_new_cnn, self))
    self.cnn:set_close_cb(Functional.make_closure(self._on_close_cnn, self))

    local login_cfg = self.service.all_service_cfg:get_game_service(self.service.zone_name, Service_Const.Login, 0)
    Net.connect("127.0.0.1", login_cfg[Service_Const.Client_Port], self.cnn)
end

function LoginAction:stop()
    LoginAction.super.stop(self)
    self.timer_proxy:release_all()
end

function LoginAction._on_tick()
    
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

function LoginAction:_on_new_cnn(cnn, error_code)
    if 0 == error_code then
        self.co = ex_coroutine_create(
                Functional.make_closure(self.robot_main_logic, self),
                Functional.make_closure(self.robot_over_logic, self)
        )
        local is_ok, msg = ex_coroutine_start(self.co, self.co)
        log_debug("start robot main logic ret:%s", is_ok)
    end
end

function LoginAction:_on_close_cnn(cnn, error_code)
    if self.cnn == cnn and self.co then
        ex_coroutine_kill(self.co)
        self.co = nil
    end
end

function LoginAction:robot_over_logic(co)
    self.co = nil
    if not co:get_return_vals() then
        log_debug("LoginAction:robot_over_logic %s", co:get_error_msg())
    end
end

function LoginAction:robot_main_logic(co)
    log_debug("LoginAction:robot_main_logic 1")

    local login_params = {
        appid="for_test",
        username = "lxl11",
        pwd = "pwd",
    }
    local login_param_strs = {}
    for k, v in pairs(login_params) do
        table.insert(login_param_strs, string.format("%s=%s", k, v))
    end
    local platform_cfg = self.service.all_service_cfg:get_third_party_service(Service_Const.Platform_Service, Service_Const.For_Test)
    local host = string.format("%s:%s", platform_cfg[Service_Const.Ip], platform_cfg[Service_Const.Port])
    local url = string.format("%s/%s?%s", host, "login", table.concat(login_param_strs, "&"))
    log_debug("url = %s", url)
    local co_ok, http_ret = HttpClient.co_get(url, {})
    if not co_ok then
        return
    end
    local rsp_state, body_str = http_ret.state, http_ret.body
    log_debug("login_platform body_str %s %s",rsp_state,  body_str)
    if "OK" ~= rsp_state then
        return
    end
    local platform_login_ret = rapidjson.decode(body_str)
    log_debug("platform_login_ret %s", platform_login_ret)

    send_msg(self.cnn, ProtoId.req_login_game, {
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
    Net.close(self.cnn:netid())

    self.cnn = PidBinCnn:new()
    self.cnn:set_recv_cb(Functional.make_closure(self.on_cnn_recv, self))
    self.cnn:set_open_cb(function(cnn, error_code)
        ex_coroutine_delay_resume(co, error_code)
    end)
    self.cnn:set_close_cb(Functional.make_closure(self._on_close_cnn, self))
    Net.connect_async(msg.gate_ip, msg.gate_port, self.cnn)
    local cnn_error_code = 0
    co_ok, cnn_error_code = ex_coroutine_yield(co)
    if not co_ok and 0 ~= cnn_error_code then
        return
    end
    log_debug("to comunicate with gate")

    send_msg(self.cnn, ProtoId.req_user_login, {
        user_id = msg.user_id,
        app_id = msg.app_id,
        auth_sn = msg.auth_sn,
        auth_ip = msg.auth_ip,
        auth_port = msg.auth_port,
    })
    co_ok, pid, msg = ex_coroutine_yield(co)
    if not co_ok then
        return
    end
    log_debug("req_user_login msg:%s", msg)
    if 0 ~= msg.error_num then
        return
    end
    local role_ids = {}
    send_msg(self.cnn, ProtoId.req_pull_role_digest, {
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
    send_msg(self.cnn, ProtoId.req_create_role, {
        params = nil
    })
    co_ok, pid, msg = ex_coroutine_yield(co)
    if not co_ok then
        return
    end
    log_debug("req_create_role msg:%s", msg)
    if 0 == msg.error_num then
        send_msg(self.cnn, ProtoId.req_pull_role_digest, {
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
    send_msg(self.cnn, ProtoId.req_launch_role, {
        role_id = role_ids[1]
    })
    co, pid, msg = ex_coroutine_yield(co)
    log_debug("req_launch_role:%s", msg)
    if not co then
        return
    end
    log_debug("robot run complete successfully!!!")
end
