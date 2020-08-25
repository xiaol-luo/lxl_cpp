
---@class GameGateNetEditor:GameGateNetBase
GameGateNetEditor = class("GameGateNetEditor", GameGateNetBase)

function GameGateNetEditor:ctor(net_mgr)
    GameGateNetEditor.super.ctor(self, net_mgr)
    self._is_ready = false
    self._error_msg = nil
    self._error_num = nil
    ---@type GameNet
    self._net = nil
    self._connect_op_seq = 0
    self._next_seq = make_sequence(1)
    self._gate_ip = nil
    self._gate_port = nil
end

function GameGateNetEditor:_on_init()
end

function GameGateNetEditor:_on_release()

end

function GameGateNetEditor:connect()
    local old_is_ready = self:is_ready()
    if self._net then
        self._net:close()
        -- self._net:release()
        self._net = nil
    end
    self._error_num = nil
    self._error_msg = nil
    if old_is_ready ~= self:is_ready() then
        self:notify_ready_change()
    end

    local gate_ip, gate_port = self:get_gate_host()
    if not gate_ip or #gate_ip <= 0 or not gate_port then
        self._error_msg = string.format("gate_ip %s or gate_port %s, is not valid", gate_ip, gate_port)
        self:notify_connect_done()
        return false
    end

    local next_seq = self._next_seq()
    self._connect_op_seq = next_seq

    self._net = GameNet:new(
            Functional.make_closure(self._on_event_net_open, self, next_seq),
            Functional.make_closure(self._on_event_net_close, self, next_seq),
            Functional.make_closure(self.on_event_net_recv_msg, self, next_seq))
    self._net:connect(gate_ip, gate_port)
    return true
end

function GameGateNetEditor:disconnect()
    if self._net then
        self._net:close()
        self._net = nil
    end
end

function GameGateNetEditor:reconnect()
    return self._is_connecting
end


function GameGateNetBase:get_gate_host()
    return self._gate_ip, self._gate_port
end

function GameGateNetEditor:get_error_msg()
    return self._error_msg or ""
end

function GameGateNetEditor:is_ready()
    if Error_None ~= self._error_num then
        return false
    end
    if nil == self._net or self._net:get_state() ~= Net_Agent_State.connected then
        return false
    end
    return true
end

function GameGateNetEditor:is_connecting()
    local ret = false
    if self._net and self._net:get_state() == Net_Agent_State.connecting then
        ret = true
    end
    return ret
end

function GameGateNetEditor:get_error_msg()
    return self._error_msg
end

function GameGateNetEditor:_on_event_net_open(connect_op_seq, is_succ)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end
    log_print("GameGateNetEditor:_on_event_net_open", is_succ)
    -- self:on_open(is_succ)
    if is_succ then
        local user_id = self._net_mgr.game_login_net:get_user_id()
        local app_id = self._net_mgr.game_platform_net:get_app_id()
        local token, token_timestamp = self._net_mgr.game_login_net:get_token()
        local auth_ip, auth_port = self._net_mgr.game_login_net:get_auth_host()
        self:send_msg_to_gate(Login_Pid.req_user_login, {
            user_id = user_id,
            app_id = app_id,
            token = token,
            token_timestamp = token_timestamp,
            auth_ip = auth_ip,
            auth_port = auth_port,
        })
    else
        self._error_msg = "connect fail"
        self:notify_connect_done()
    end
end

function GameGateNetEditor:_on_event_net_close(connect_op_seq, error_num, error_msg)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end
    log_print("GameGateNetEditor:_on_event_net_close", error_num, error_msg)
    -- self:on_close(error_num, error_msg)
end

function GameGateNetEditor:on_event_net_recv_msg(connect_op_seq, pto_id, bytes, data_len)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end
    local is_ok, msg = true, nil
    if self._pto_parser:exist(pto_id) then
        is_ok, msg = self._pto_parser:decode(pto_id, bytes)
    end
    if not is_ok then
        log_error("GameGateNetEditor:on_event_net_recv_msg pto_parser:decode fail, pid %s", pto_id)
        return
    end

    log_print("GameGateNetEditor:on_event_net_recv_msg", pto_id, is_ok, msg)
    if Login_Pid.rsp_user_login == pto_id then
        local old_is_ready = self:is_ready()
        self._error_num = msg.error_num
        if old_is_ready ~= self:is_ready() then
            self:notify_ready_change()
        end
        self:notify_connect_done()
        return
    end

    log_print("GameGateNetEditor:on_event_net_recv_msg 222", pto_id, is_ok, msg)
    self._net_mgr:fire(pto_id, pto_id, msg)
end

function GameGateNetEditor:send_msg_to_gate(pto_id, msg)
    if not self._net or self._net:get_state() ~= Net_Agent_State.connected then
        return false
    end
    local is_ok, bin = self._pto_parser:encode(pto_id, msg)
    if is_ok then
        return self._net:send(pto_id, bin)
    end
    return false
end

function GameGateNetEditor:send_msg(pto_id, msg)
    local is_ok, bytes = true, nil
    if is_table(msg) then
        is_ok, bytes = self._pto_parser:encode(pto_id, msg)
    else
        is_ok = false
    end
    if not is_ok then
        log_error("GameGateNetEditor:send_msg encode fail, pid %s, msg %s", pto_id, msg)
        return false
    end

    is_ok = self:send_msg_to_gate(Forward_Msg_Pid.req_forward_game_msg, { msg = {
        pto_id = pto_id,
        pto_bytes = bytes,
        further_forward = 0,
    }})
    return is_ok
end



