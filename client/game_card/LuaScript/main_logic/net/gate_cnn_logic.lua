
GateCnnLogic = GateCnnLogic or class("GateCnnLogic", CnnLogicBase)

declare_event_set("Event_Set__Gate_Cnn_Logic", {
    "open",
    "close",
    "login_done",
})

function GateCnnLogic:ctor(main_logic)
    self.main_logic = main_logic
    self._is_done = false
    self.error_code = -1
    self.user_info = nil
    self.msg_handlers = {}
    self.msg_handlers[ProtoId.rsp_user_login] = Functional.make_closure(self.on_msg_rsp_user_login, self)
    self.msg_handlers[ProtoId.req_pull_role_digest] = Functional.make_closure(self.on_msg_rsp_pull_role_digest, self)
end

function GateCnnLogic:on_reset()
    self._is_done = false
    self.error_code = 0
    self.user_info = nil
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
        -- log_debug("LoginCnnLogic:on_open send bin %s %s", #bin, bin)
        self.cnn:send(ProtoId.req_user_login, bin)
    end
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.open, self, is_succ)
end

function GateCnnLogic:on_close(error_num, error_msg)
    self.main_logic.event_mgr:fire(Event_Set__Gate_Cnn_Logic.close, self, error_num, error_msg)
end

function GateCnnLogic:on_update()

end

function GateCnnLogic:on_recv_msg(proto_id, bytes, data_len)
    log_debug("LoginCnnLogic:on_recv_msg %s %s %s", proto_id, data_len, bytes)
    local msg_handler = self.msg_handlers[proto_id]
    if msg_handler then
        local is_ok, msg = self.main_logic.proto_parser:decode(proto_id, bytes)
        if is_ok then
            msg_handler(proto_id, msg)
        else
            log_error("GateCnnLogic:on_recv_msg decode fail. proto id %s", proto_id)
        end
    else
        log_error("GateCnnLogic:on_recv_msg no msg handler for proto id %s", proto_id)
    end
end

function GateCnnLogic:on_msg_rsp_user_login(proto_id, msg)
    log_debug("GateCnnLogic:on_msg_rsp_user_login %s %s", proto_id, msg)
    if 0 == msg.error_num then
        self.cnn:send_msg(ProtoId.req_pull_role_digest, { role_id = 0 })
    end
end

function GateCnnLogic:on_msg_rsp_pull_role_digest(proto_id, msg)
    log_debug("GateCnnLogic:on_msg_rsp_pull_role_digest %s %s", proto_id, msg)
end
