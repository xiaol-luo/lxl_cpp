
GateCnnLogic = GateCnnLogic or class("GateCnnLogic", CnnLogicBase)

declare_event_set("Event_Set__Gate_Cnn_Logic", {
    "open",
    "close",
    "rsp_role_digests",
    "rsp_launch_role",
})

function GateCnnLogic:ctor(main_logic)
    self.main_logic = main_logic
    self._is_done = false
    self.error_code = -1
    self.user_info = nil
    self.msg_handlers = {}
    self.msg_handlers[ProtoId.rsp_user_login] = Functional.make_closure(self.on_msg_rsp_user_login, self)
    self.msg_handlers[ProtoId.rsp_pull_role_digest] = Functional.make_closure(self.on_msg_rsp_pull_role_digest, self)
    self.msg_handlers[ProtoId.rsp_create_role] = Functional.make_closure(self.on_msg_rsp_create_role, self)
    self.msg_handlers[ProtoId.rsp_launch_role] = Functional.make_closure(self.on_msg_rsp_launch_role, self)
    self.msg_handlers[ProtoId.pong] = Functional.make_closure(self.on_msg_pong, self)
    self.role_digests = {}
    self.is_launched_role = false
    self.launch_role_error_num = 0
    self.last_ping_sec = 0
    self.default_msg_handler = Functional.make_closure(self.on_fire_msg, self)
end

function GateCnnLogic:on_reset()
    self._is_done = false
    self.error_code = 0
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
    self.is_launched_role = false
    self.launch_role_error_num = 0
end

function GateCnnLogic:on_open(is_succ)
    if is_succ then
        local is_ok, bin = self.main_logic.proto_parser:encode(ProtoId.req_user_login, {
            user_id = self.user_info.user_id,
            app_id = self.user_info.app_id,
            auth_sn = self.user_info.auth_sn,
            auth_ip = self.user_info.auth_ip,
            auth_port = self.user_info.auth_port,
            account_id = self.user_info.account_id,
            ignore_auth = true,
        })
        log_assert(is_ok, "encode proto %s fail %s", self.main_logic.proto_parser:get_proto_desc(ProtoId.req_user_login))
        log_debug("LoginCnnLogic:on_open send bin %s %s", #bin, bin)
        self.cnn:send(ProtoId.req_user_login, bin)
    end
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.open, self, is_succ)
end

function GateCnnLogic:on_close(error_num, error_msg)
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.close, self, error_num, error_msg)
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
    if 0 == msg.error_num then
        self.cnn:send_msg(ProtoId.req_pull_role_digest, { role_id = nil })
    end
end

function GateCnnLogic:on_msg_rsp_pull_role_digest(proto_id, msg)
    log_debug("GateCnnLogic:on_msg_rsp_pull_role_digest %s %s", proto_id, msg)
    self.role_digests = msg.role_digests
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.rsp_role_digests, self, msg)
end

function GateCnnLogic:on_msg_rsp_create_role(proto_id, msg)
    log_debug("GateCnnLogic:on_msg_rsp_create_role %s %s", proto_id, msg)
    self.cnn:send_msg(ProtoId.req_pull_role_digest, { role_id = nil })
end

function GateCnnLogic:on_msg_rsp_launch_role(proto_id, msg)
    log_debug("GateCnnLogic:on_msg_rsp_launch_role %s %s", proto_id, msg)
    self.launch_role_error_num = msg.error_num
    if 0 == msg.error_num then
        self.is_launched_role = true
    end
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.rsp_launch_role, self, msg)
    self:send_msg_to_game(ProtoId.pull_match_state)
    self:send_msg_to_game(ProtoId.pull_room_state)
    self:send_msg_to_game(ProtoId.pull_remote_room_state)
end


function GateCnnLogic:on_fire_msg(proto_id, msg)
    log_debug("GateCnnLogic:on_fire_msg %s %s", proto_id, msg)
    self.main_logic.event_mgr:fire(proto_id, proto_id, msg)
end

function GateCnnLogic:on_msg_pong(proto_id, msg)

end

function GateCnnLogic:pull_role_digest(role_id)
    return self:send_msg(ProtoId.req_pull_role_digest, {role_id = role_id })
end

function GateCnnLogic:create_role(params)
    return self:send_msg(ProtoId.req_create_role, { params = params })
end

function GateCnnLogic:launch_role(role_id)
    return self:send_msg(ProtoId.req_launch_role, { role_id = role_id } )
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

