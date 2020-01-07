
local ACCOUNT_ID = "LXL_1"
local APPID_ID = "FOR_TEST_APP_ID"
local PLATFORM_NAME = "FOR_TEST_PLATFORM_NAME"
local TOKEN = "FOR_TEST_TOKEN"

LoginCnnLogic = LoginCnnLogic or class("LoginCnnLogic", CnnLogicBase)

declare_event_set("Event_Set__Login_Cnn_Logic", {
    "open",
    "close",
    "login_done",
})

function LoginCnnLogic:ctor(main_logic)
    self.main_logic = main_logic
    self._is_done = false
    self.error_code = -1
    self.user_info = nil
    self.msg_handlers = {}
    self.msg_handlers[ProtoId.rsp_login_game] = Functional.make_closure(self.on_msg_rsp_login_game, self)
end

function LoginCnnLogic:on_open(is_succ)
    if is_succ then
        local is_ok, bin = self.main_logic.proto_parser:encode(ProtoId.req_login_game, {
            token = TOKEN,
            timestamp = os.time(),
            platform = PLATFORM_NAME,
            ignore_auth = true,
            force_account_id = ACCOUNT_ID,
        })
        log_assert(is_ok, "encode proto %s fail %s", self.main_logic.proto_parser:get_proto_desc(ProtoId.req_login_game))
        -- log_debug("LoginCnnLogic:on_open send bin %s %s", #bin, bin)
        self.cnn:send(ProtoId.req_login_game, bin)
    end
    self.main_logic.event_mgr:fire(Event_Set__Login_Cnn_Logic.open, self, is_succ)
end

function LoginCnnLogic:on_recv_msg(proto_id, bytes, data_len)
    log_debug("LoginCnnLogic:on_recv_msg %s %s %s", proto_id, data_len, bytes)
    local msg_handler = self.msg_handlers[proto_id]
    if msg_handler then
        local is_ok, msg = self.main_logic.proto_parser:decode(proto_id, bytes)
        if is_ok then
            msg_handler(proto_id, msg)
        else
            log_error("LoginCnnLogic:on_recv_msg decode fail. proto id %s", proto_id)
        end
    else
        log_error("LoginCnnLogic:on_recv_msg no msg handler for proto id %s", proto_id)
    end
end

function LoginCnnLogic:on_close(error_num, error_msg)
    self.main_logic.event_mgr:fire(Event_Set__Login_Cnn_Logic.close, self, error_num, error_msg)
end

function LoginCnnLogic:on_update()

end

function LoginCnnLogic:on_reset()
    self._is_done = false
    self.error_code = 0
    self.user_info = nil
end

function LoginCnnLogic:is_done()
    return self._is_done
end

function LoginCnnLogic:on_msg_rsp_login_game(proto_id, msg)
    self._is_done = true
    self.user_info = nil
    if msg and msg.error_code then
        self.error_code = msg.error_code
        if 0 == self.error_code then
            self.user_info = {}
            self.user_info.app_id = APPID_ID
            self.user_info.gate_ip = msg.gate_ip
            self.user_info.gate_port = msg.gate_port
            self.user_info.user_id = msg.user_id
            self.user_info.auth_sn = msg.auth_sn
            self.user_info.auth_ip = msg.auth_ip
            self.user_info.auth_port = msg.auth_port
            self.user_info.account_id = msg.account_id
            self.user_info.timestamp = msg.timestamp
            self.user_info.ignore_auth = true
        end
    end
    self.main_logic.event_mgr:fire(Event_Set__Login_Cnn_Logic.login_done, self, self.error_code, self.user_info)
    log_debug("LoginCnnLogic:on_msg_rsp_login_game %s %s user_info:%s", proto_id, msg, self.user_info)
    self:close()
end



