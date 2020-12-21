
---@class FightNetEditor:FightNetEditor
FightNetEditor = class("FightNetEditor", FightNetBase)

function FightNetEditor:ctor(net_mgr)
    FightNetEditor.super.ctor(self, net_mgr)
    self._is_ready = false
    self._error_msg = nil
    ---@type GameNet
    self._net = nil
    self._connect_op_seq = 0
    self._next_seq = make_sequence(1)
    self._fight_ip = nil
    self._fight_port = nil
end

function FightNetEditor:_on_init()

end

function FightNetEditor:_on_release()

end

function FightNetEditor:connect()
    if self._net then
        self._net:close()
        self._net = nil
    end
    self._error_msg = nil
    self:notify_ready_state()

    local fight_ip, fight_port = self:get_host()
    if not fight_ip or #fight_ip <= 0 or not fight_port then
        self._error_msg = string.format("fight_ip %s or fight_port %s, is not valid", fight_ip, fight_port)
        self:notify_connect_done()
        return false
    end

    local next_seq = self._next_seq()
    self._connect_op_seq = next_seq

    self._net = GameNet:new(
            Functional.make_closure(self._on_event_net_open, self, next_seq),
            Functional.make_closure(self._on_event_net_close, self, next_seq),
            Functional.make_closure(self.on_event_net_recv_msg, self, next_seq))
    self._net:connect(fight_ip, fight_port)
    return true
end

function FightNetEditor:disconnect()
    if self._net then
        self._net:close()
        self._net = nil
    end
end

function FightNetEditor:get_host()
    return self._fight_ip, self._fight_port
end

function FightNetBase:set_host(ip, port)
    self._fight_ip = ip
    self._fight_port = port
end

function FightNetEditor:get_error_msg()
    return self._error_msg
end

function FightNetEditor:is_ready()
    if self:get_error_msg() then
        return false
    end
    if nil == self._net or self._net:get_state() ~= Net_Agent_State.connected then
        return false
    end
    return true
end

function FightNetEditor:is_connecting()
    local ret = false
    if self._net and self._net:get_state() == Net_Agent_State.connecting then
        ret = true
    end
    return ret
end

function FightNetEditor:_on_event_net_open(connect_op_seq, is_succ)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end
    log_print("FightNetEditor:_on_event_net_open", is_succ)
    if not is_succ then
        self._error_msg = "connect fail"
    end
    self:notify_connect_done()
    self:notify_ready_state()
end

function FightNetEditor:_on_event_net_close(connect_op_seq, error_num, error_msg)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end
    log_print("FightNetEditor:_on_event_net_close", error_num, error_msg)
    self:notify_ready_state()
end

function FightNetEditor:on_event_net_recv_msg(connect_op_seq, pto_id, bytes, data_len)
    if self._connect_op_seq ~= connect_op_seq then
        return
    end
    local is_ok, msg = true, nil
    if self._pto_parser:exist(pto_id) then
        is_ok, msg = self._pto_parser:decode(pto_id, bytes)
    end
    log_print("FightNetEditor:on_event_net_recv_msg ", pto_id, msg)
    if not is_ok then
        log_error("FightNetEditor:on_event_net_recv_msg pto_parser:decode fail, pid %s", pto_id)
        return
    end
    self._net_mgr:fire(pto_id, pto_id, msg)
end

function FightNetEditor:send_msg(pto_id, msg)
    if not self._net or self._net:get_state() ~= Net_Agent_State.connected then
        return false
    end
    local is_ok, bin = self._pto_parser:encode(pto_id, msg)
    if is_ok then
        return self._net:send(pto_id, bin)
    end
    return false
end



