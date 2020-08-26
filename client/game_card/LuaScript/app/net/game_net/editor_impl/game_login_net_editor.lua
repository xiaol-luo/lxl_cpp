
---@class GameLoginNetEditor:GameLoginNetBase
GameLoginNetEditor = class("GameLoginNetEditor", GameLoginNetBase)

function GameLoginNetEditor:ctor(net_mgr)
    GameLoginNetEditor.super.ctor(self, net_mgr)
    self._is_ready = false
    self._error_msg = nil

    -- datas from login server
    self._user_id = nil
    self._token = nil
    self._token_timestamp = nil
    self._auth_ip = nil
    self._auth_port = nil

    ---@type GameNet
    self._net = nil
    self._login_ip = nil
    self._login_port = nil
    self._connect_op_seq = 0
    self._next_seq = make_sequence(1)
    self._trying_login = false
    self._pto_parser = self._net_mgr._pto_parser
end

function GameLoginNetEditor:_on_init()
end

function GameLoginNetEditor:_on_release()

end

function GameLoginNetEditor:login()
    self:logout()

    local next_seq = self._next_seq()
    self._connect_op_seq = next_seq

    self._net = GameNet:new(
            Functional.make_closure(self._on_event_net_open, self, next_seq),
            Functional.make_closure(self._on_event_net_close, self, next_seq),
            Functional.make_closure(self.on_event_net_recv_msg, self, next_seq))
    self._net:connect(self._login_ip, self._login_port)
    self._trying_login = true
    self:notify_login_start()
end

function GameLoginNetEditor:logout()
    self._is_ready = false
    self._user_id = nil
    self._auth_sn = nil
    self._gate_hosts = nil
    self._error_msg = nil
    if self._net then
        self._net:close()
        self._net = nil
    end
    self._trying_login = false
    self:_set_is_ready(false)
end

function GameLoginNetEditor:is_ready()
    return self._is_ready
end

function GameLoginNetEditor:get_error_msg()
    return self._error_msg
end

function GameLoginNetEditor:get_user_id()
    return self._user_id
end

function GameLoginNetEditor:get_token()
    return self._token, self._token_timestamp
end

function GameLoginNetEditor:get_auth_host()
    return self._auth_ip, self._auth_port
end

function GameLoginNetEditor:_on_event_net_open(connect_op_seq, is_succ)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end

    log_print("GameLoginNetEditor:_on_event_net_open", is_succ)
    if self._trying_login then
        if not is_succ then
            self._trying_login = false
            self:_set_is_ready(false, "connect login server fail")
            self:notify_login_done()
        else
            local game_platform_net = self._net_mgr.game_platform_net
            local account_id = game_platform_net:get_account_id()
            local token, token_timestamp = game_platform_net:get_token()
            local platform = game_platform_net:get_platform_name()
            local app_id = game_platform_net:get_app_id()
            local send_ret = self:send_msg(Login_Pid.req_login_user, {
                token = token,
                timestamp = token_timestamp,
                platform = platform,
                app_id = app_id,
                account_id = account_id,
            })
            if not send_ret then
                log_error("GameLoginNetEditor:_on_event_net_open send msg Login_Pid.req_login_user fail")
                self._trying_login = false
                self:_set_is_ready(false, "GameLoginNetEditor:_on_event_net_open send msg Login_Pid.req_login_user fail")
                self:notify_login_done()
            end
        end
    end
end

function GameLoginNetEditor:_on_event_net_close(connect_op_seq, error_num, error_msg)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end

    if self._trying_login then
        self._trying_login = false
        self:_set_is_ready(false, "connection with login server closed")
        self:notify_login_done()
    end
end

function GameLoginNetEditor:on_event_net_recv_msg(connect_op_seq, pto_id, bytes, data_len)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end
    local is_ok, msg = true, nil
    if self._pto_parser:exist(pto_id) then
        is_ok, msg = self._pto_parser:decode(pto_id, bytes)
    end
    if not is_ok then
        log_error("GameLoginNetEditor:on_event_net_recv_msg pto_parser:decode fail, pid %s", pto_id)
        return
    end

    log_print("GameLoginNetEditor:on_event_net_recv_msg", pto_id, is_ok, msg)
    if Login_Pid.rsp_login_user == pto_id then
        self._trying_login = false
        if Error_None == msg.error_num then
            self:_set_is_ready(true)
            self._token = msg.token
            self._token_timestamp = tostring(msg.timestamp)
            self._user_id = msg.user_id
            self._auth_ip = msg.auth_ip
            self._auth_port = msg.auth_port
        else
            self:_set_is_ready(false, string.format("Login_Pid.rsp_login_user error %s", msg.error_num))
        end
        self:notify_login_done()
        self._net:close()
        self._net = nil
        return
    end
end

function GameLoginNetEditor:send_msg(pto_id, msg)
    if not self._net or self._net:get_state() ~= Net_Agent_State.connected then
        return false
    end
    local is_ok, bin = self._pto_parser:encode(pto_id, msg)
    if is_ok then
        return self._net:send(pto_id, bin)
    end
    return false
end

function GameLoginNetEditor:_set_is_ready(is_ready, error_msg)
    local old_is_ready = self._is_ready
    self._is_ready = is_ready
    self._error_msg = error_msg
    if old_is_ready ~= self._is_ready then
        self:notify_ready_change()
    end
end








