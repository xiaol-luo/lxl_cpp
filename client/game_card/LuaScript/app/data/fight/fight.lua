
---@class Fight:DataBase
Fight = Fight or class("Fight", DataBase)

assert(DataBase)

function Fight:ctor(data_mgr)
    Fight.super.ctor(self, data_mgr, "fight")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net
    ---@type FightNetBase
    self._fight_net = self._app.net_mgr.fight_net

    self.fight_data = {}
end

function Fight:_on_init()
    Fight.super._on_init(self)

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_join_match, Functional.make_closure(self._on_msg_rsp_join_match, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_quit_match, Functional.make_closure(self._on_msg_sync_rsp_quit_match, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_match_state, Functional.make_closure(self._on_msg_sync_match_state, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_room_state, Functional.make_closure(self._on_msg_sync_room_state, self))

    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.fight_connect_done, Functional.make_closure(self._on_fight_net_connect_done, self))
end

function Fight:_on_release()
    Fight.super._on_release(self)
end

---@param match_theme Match_Theme
---@param teammate_role_ids table<number, number>
function Fight:req_join_match(match_theme, teammate_role_ids)
    self._gate_net:send_msg(Fight_Pid.req_join_match, {
        match_theme = match_theme,
        teammate_role_ids = teammate_role_ids,
    })
end

function Fight:req_quit_match()
    self._gate_net:send_msg(Fight_Pid.req_quit_match, {
        match_key = "",
        ignore_match_key = true,
    })
end

function Fight:req_match_state()
    self._gate_net:send_msg(Fight_Pid.pull_match_state)
end

function Fight:_on_msg_rsp_join_match(pid, msg)
    log_print("Fight:_on_msg_rsp_join_match(pid, msg)", pid, msg)
end

function Fight:_on_msg_sync_rsp_quit_match(pid, msg)
    log_print("Fight:_on_msg_sync_rsp_quit_match(pid, msg)", pid, msg)
end

function Fight:_on_msg_sync_match_state(pid, msg)
    log_print("Fight:_on_msg_sync_match_state(pid, msg)", pid, msg)
end

function Fight:_on_msg_sync_room_state(pid, msg)
    log_print("Fight:_on_msg_sync_room_state(pid, msg)", pid, msg)

    if msg.remote_room_state == Room_State.in_fight then
        self._fight_net:set_host(msg.fight_server_ip, msg.fight_server_port)
        self._fight_net:connect()
    end
    self.fight_data = msg
end

function Fight:_on_fight_net_connect_done(is_ready, error_msg)
    log_print("Fight:_on_fight_net_connect_done", is_ready, error_msg)
    if is_ready then
        self._fight_net:send_msg(Fight_Pid.req_bind_fight, {
            fight_key = self.fight_data.fight_key,
            token = self.fight_data.fight_token,
            role_id = self._data_mgr.main_role:get_role_id(),
        })
    else

    end
end


