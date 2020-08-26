

declare_event_set("Event_Set__Gate_Cnn_Logic", {
    "open",
    "close",
    "login_gate_result",
    "relogin_gate_result",
})

GateCnnLogic = GateCnnLogic or class("GateCnnLogic", CnnLogicBase)

function GateCnnLogic:ctor(main_logic)
    self.main_logic = main_logic
    self.user_info = nil
    self.msg_handlers = {}
    self.msg_handlers[ProtoId.rsp_user_login] = Functional.make_closure(self.on_msg_rsp_user_login, self)
    self.msg_handlers[ProtoId.rsp_reconnect] = Functional.make_closure(self.on_msg_rsp_reconnect, self)
    self.msg_handlers[ProtoId.pong] = Functional.make_closure(self.on_msg_pong, self)

    self.is_logined = false
    self.login_error_num = 0
    self.is_connected = false
    self.connect_error_num = 0
    self.try_relogin_fail = false

    self.last_ping_sec = 0
    self.default_msg_handler = Functional.make_closure(self.on_fire_msg, self)
end

function GateCnnLogic:set_user_info(gate_ip, gate_port, user_id, auth_sn, auth_ip, auth_port, account_id, app_id)
    self:reset(gate_ip, gate_port)
    self.user_info = {}
    self.user_info.gate_ip = gate_ip
    self.user_info.gate_port = gate_port
    self.user_info.user_id = user_id
    self.user_info.auth_sn = auth_sn
    self.user_info.auth_ip = auth_ip
    self.user_info.auth_port = auth_port
    self.user_info.account_id = account_id
    self.user_info.app_id = app_id
end

function GateCnnLogic:on_reset()
    self.is_logined = false
    self.login_error_num = 0
    self.is_connected = false
    self.connect_error_num = 0
    self.try_relogin_fail = false
end

function GateCnnLogic:send_to_game(proto_id, proto_bytes)
    local ret = self:send_msg(ProtoId.req_client_forward_game, {
        proto_id = proto_id,
        proto_bytes = proto_bytes,
    })
    return ret
end

function GateCnnLogic:send_msg_to_game(proto_id, msg)
    local is_ok, block = true, nil
    if self.main_logic.proto_parser:exist(proto_id) then
        is_ok, block = self.main_logic.proto_parser:encode(proto_id, msg)
        if not is_ok then
            return false
        end
    end
    return self:send_to_game(proto_id, block)
end

function GateCnnLogic:login_gate(is_reconnect)
    local login_gate_data = {
        user_id = self.user_info.user_id,
        app_id = self.user_info.app_id,
        auth_sn = self.user_info.auth_sn,
        auth_ip = self.user_info.auth_ip,
        auth_port = self.user_info.auth_port,
        account_id = self.user_info.account_id,
        ignore_auth = true,
    }
    local is_ok = false
    if is_reconnect then
        log_assert(self.main_logic.main_role.role_id, "unexpected error")
        is_ok = self:send_msg(ProtoId.req_reconnect, {
            role_id = self.main_logic.main_role.role_id,
            login_gate_data = login_gate_data
        })
    else
        is_ok = self:send_msg(ProtoId.req_user_login, login_gate_data)
    end
    log_assert(is_ok, "unexpected error")
    return is_ok
end

function GateCnnLogic:on_open(is_succ)
    if is_succ then
        if self.main_logic.main_role.role_id and not self.try_relogin_fail then
            self:login_gate(true)
        else
            self:login_gate(false)
        end
    end
    self.is_connected = is_succ
    self.connect_error_num = 0
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.open, self, is_succ)
end

function GateCnnLogic:on_close(error_num, error_msg)
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.close, self, error_num, error_msg)
    self.is_logined = false
    self.login_error_num = 0
    self.is_connected = false
    self.connect_error_num = error_num
end

function GateCnnLogic:on_update()
    if Net_Agent_State.connected == self:get_state() then
        local now_sec = logic_sec()
        if now_sec - self.last_ping_sec > 1 then
            self.last_ping_sec = now_sec
            self.cnn:send_msg(ProtoId.ping)
        end
    end
end

function GateCnnLogic:on_recv_msg(proto_id, bytes, data_len)
    -- log_debug("LoginCnnLogic:on_recv_msg %s %s %s", proto_id, data_len, bytes)
    local msg_handler = self.msg_handlers[proto_id] or self.default_msg_handler

    local is_ok, msg = self.main_logic.proto_parser:decode(proto_id, bytes)
    if is_ok then
        msg_handler(proto_id, msg)
    else
        log_error("GateCnnLogic:on_recv_msg decode fail. proto id %s", proto_id)
    end
end

function GateCnnLogic:on_msg_rsp_user_login(proto_id, msg)
    log_debug("GateCnnLogic:on_msg_rsp_user_login %s %s", proto_id, msg)
    self.login_error_num = msg.error_num
    if Error_None == msg.error_num then
        self.is_logined = true
        self.try_relogin_fail = false
    end
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.login_gate_result, self, msg.error_num)
end

function GateCnnLogic:on_msg_rsp_reconnect(proto_id, msg)
    self.login_error_num = msg.error_num
    if Error_None == msg.error_num then
        self.is_logined = true
    else
        self.try_relogin_fail = true
    end
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.relogin_gate_result, self, msg.error_num)
end

function GateCnnLogic:on_msg_pong(proto_id, msg)

end

function GateCnnLogic:on_fire_msg(proto_id, msg)
    log_debug("GateCnnLogic:on_fire_msg %s %s", proto_id, msg)
    self.main_logic.msg_event_mgr:fire(proto_id, proto_id, msg)
    self.main_logic.event_mgr:fire(proto_id, proto_id, msg)
end
