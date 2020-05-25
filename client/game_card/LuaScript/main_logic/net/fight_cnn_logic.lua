
declare_event_set("Event_Set__Fight_Cnn_Logic", {
    "open",
    "close",
    "bind_fight",
})

FightCnnLogic = FightCnnLogic or class("FightCnnLogic", CnnLogicBase)

function FightCnnLogic:ctor(main_logic)
    self.main_logic = main_logic
    self.fight_info = nil
    self.is_binded = false
    self.is_connected = false
    self.try_reconnect_times = 0

    self.last_ping_sec = 0
    self.default_msg_handler = Functional.make_closure(self.on_fire_msg, self)
    self.msg_handlers = {}

    self.is_active = false
end

function FightCnnLogic:set_active(is_active)
    self.is_active = is_active
    if not self.is_active then
        self:close()
    end
end

function FightCnnLogic:get_is_active()
    return self.is_active
end

function FightCnnLogic:set_fight_info(fight_ip, fight_port, fight_id, fight_session_id, role_id)
    self:reset(fight_ip, fight_port)
    self.fight_info = {
        fight_ip = fight_ip,
        fight_port = fight_port,
        fight_id = fight_id,
        fight_session_id = fight_session_id,
        role_id = role_id,
    }
end

function FightCnnLogic:on_reset()
    self.is_active = false
    self.fight_info = nil
    self.is_binded = false
    self.bind_error_num = 0
    self.is_connected = false
    self.connect_error_num = 0
    self.try_reconnect_times = 0
end

function FightCnnLogic:on_open(is_succ)
    log_debug("FightCnnLogic:on_open %s", is_succ)
    if is_succ then
        -- bind fight
        self:send_msg(ProtoId.req_bind_fight, {
            fight_id = self.fight_info.fight_id,
            fight_session_id = self.fight_info.fight_session_id,
            role_id = self.fight_info.role_id,
        })
    else
        self.try_reconnect_times = self.try_reconnect_times + 1
    end
    self.is_connected = is_succ
    self.connect_error_num = 0
    self.main_logic.event_mgr:fire(Event_Set__Fight_Cnn_Logic.open, self, is_succ)
end

function FightCnnLogic:on_close(error_num, error_msg)
    self.main_logic.event_mgr:fire(Event_Set__Fight_Cnn_Logic.close, self, error_num, error_msg)
    self.is_binded = false
    self.bind_error_num = 0
    self.is_connected = false
    self.connect_error_num = error_num
end

function FightCnnLogic:on_update()
    if Net_Agent_State.connected == self:get_state() then
        local now_sec = logic_sec()
        if now_sec - self.last_ping_sec > 1 then
            self.last_ping_sec = now_sec
            self.cnn:send_msg(ProtoId.ping)
        end
    end
end

function FightCnnLogic:on_recv_msg(proto_id, bytes, data_len)
    -- log_debug("FightCnnLogic:on_recv_msg %s %s %s", proto_id, data_len, bytes)
    local msg_handler = self.msg_handlers[proto_id] or self.default_msg_handler

    local is_ok, msg = self.main_logic.proto_parser:decode(proto_id, bytes)
    if is_ok then
        msg_handler(proto_id, msg)
    else
        log_error("FightCnnLogic:on_recv_msg decode fail. proto id %s", proto_id)
    end
end

function FightCnnLogic:on_msg_rsp_bind_fight(proto_id, msg)
    log_debug("FightCnnLogic:on_msg_rsp_bind_fight %s", msg)
    self.bind_error_num = error_num
    if Error_None == msg.error_num then
        self.is_binded = true
        self.try_reconnect_times = 0
    else
        self.is_binded = false
        self.try_reconnect_times = self.try_reconnect_times + 1
    end
    self.main_logic.event_mgr:fire(Event_Set__Fight_Cnn_Logic.bind_fight, self, self.bind_error_num)
    if not self.is_binded then
        self:close()
    end
end

function FightCnnLogic:on_fire_msg(proto_id, msg)
    log_debug("FightCnnLogic:on_fire_msg %s %s", proto_id, msg)
    self.main_logic.msg_event_mgr:fire(proto_id, proto_id, msg)
    self.main_logic.event_mgr:fire(proto_id, proto_id, msg)
end

