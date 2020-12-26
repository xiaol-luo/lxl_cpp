
---@class MatchData:DataBase
MatchData = MatchData or class("MatchData", DataBase)

assert(DataBase)

function MatchData:ctor(data_mgr)
    MatchData.super.ctor(self, data_mgr, "match")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net

end

function MatchData:_on_init()
    MatchData.super._on_init(self)

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_join_match, Functional.make_closure(self._on_msg_rsp_join_match, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_quit_match, Functional.make_closure(self._on_msg_sync_rsp_quit_match, self))
end

function MatchData:_on_release()
    Fight.super._on_release(self)
end

---@param match_theme Match_Theme
---@param teammate_role_ids table<number, number>
function MatchData:req_join_match(match_theme, teammate_role_ids)
    self._gate_net:send_msg(Fight_Pid.req_join_match, {
        match_theme = match_theme,
        teammate_role_ids = teammate_role_ids,
    })
end

function MatchData:req_quit_match()
    self._gate_net:send_msg(Fight_Pid.req_quit_match, {
        match_key = "",
        ignore_match_key = true,
    })
end

function MatchData:pull_match_state()
    self._gate_net:send_msg(Fight_Pid.pull_match_state)
end

function MatchData:_on_msg_rsp_join_match(pid, msg)
    log_print("MatchData:_on_msg_rsp_join_match(pid, msg)", pid, msg)
end

function MatchData:_on_msg_sync_rsp_quit_match(pid, msg)
    log_print("MatchData:_on_msg_sync_rsp_quit_match(pid, msg)", pid, msg)
end

function MatchData:_on_msg_sync_match_state(pid, msg)
    log_print("MatchData:_on_msg_sync_match_state(pid, msg)", pid, msg)
end



