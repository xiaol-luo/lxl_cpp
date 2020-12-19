
---@class Fight:DataBase
Fight = Fight or class("Fight", DataBase)

assert(DataBase)

function Fight:ctor(data_mgr)
    Fight.super.ctor(self, data_mgr, "fight")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net
end

function Fight:_on_init()
    Fight.super._on_init(self)

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_join_match, Functional.make_closure(self._on_msg_rsp_join_match, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_quit_match, Functional.make_closure(self._on_msg_sync_rsp_quit_match, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_match_state, Functional.make_closure(self._on_msg_sync_match_state, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_room_state, Functional.make_closure(self._on_msg_sync_room_state, self))
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
end


