
---@class GameLoginNetEditor:GameLoginNetBase
GameLoginNetEditor = class("GameLoginNetEditor", GameLoginNetBase)

function GameLoginNetEditor:ctor(net_mgr)
    GameLoginNetEditor.super.ctor(self, net_mgr)
    self._is_ready = false
    self._error_msg = nil
    self._error_num = nil

    self._user_id = nil
    self._gate_hosts = nil
    self._auth_sn = nil

    ---@type GameNet
    self._net = nil
    self._login_ip = nil
    self._login_port = nil

    self._connect_op_seq = 0
    self._next_seq = make_sequence(1)
end

function GameLoginNetEditor:_on_init()

end

function GameLoginNetEditor:_on_release()

end

function GameLoginNetEditor:login()
    local old_is_ready = self:is_ready()
    if self._net then
        self._net:close()
        self._net = nil
    end
    self._error_num = nil
    self._error_msg = nil
    if old_is_ready ~= self:is_ready() then
        self:notify_ready_change()
    end

    local next_seq = self._next_seq()
    self._connect_op_seq = next_seq

    self._net = GameNet:new(
            Functional.make_closure(self._on_event_net_open, self, next_seq),
            Functional.make_closure(self._on_event_net_close, self, next_seq),
            Functional.make_closure(self.on_event_net_recv_msg, self, next_seq))
    self._net:connect(self._login_ip, self._login_port)
end

function GameLoginNetEditor:logout()
    self._is_ready = false
    self._user_id = nil
    self._gate_hosts = nil
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

function GameLoginNetEditor:get_gate_hosts()
    return self._gate_hosts
end

function GameLoginNetEditor:get_auth_sn()
    return self._auth_sn
end



function GameLoginNetEditor:_on_event_net_open(connect_op_seq, is_succ)
    log_print("GameLoginNetEditor:_on_event_net_open", is_succ)
end

function GameLoginNetEditor:_on_event_net_close(connect_op_seq, error_num, error_msg)

end

function GameLoginNetEditor:on_event_net_recv_msg(connect_op_seq, pto_id, bytes, data_len)

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








