
---@class MatchData:DataBase
MatchData = MatchData or class("MatchData", DataBase)

assert(DataBase)

function MatchData:ctor(data_mgr)
    MatchData.super.ctor(self, data_mgr, "match")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net

    self.match_key = ""
    self.match_theme = ""
    self.state = Game_Match_Item_State.idle

    -- self:_handle_match_state_pto(nil)
end

function MatchData:_on_init()
    MatchData.super._on_init(self)

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_join_match, Functional.make_closure(self._on_msg_rsp_join_match, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_quit_match, Functional.make_closure(self._on_msg_sync_rsp_quit_match, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_match_state, Functional.make_closure(self._on_msg_sync_match_state, self))

end

function MatchData:_on_release()
    Fight.super._on_release(self)
end

---@param match_theme Match_Theme
---@param teammate_role_ids table<number, number>
function MatchData:req_join_match(match_theme, teammate_role_ids)
    if #self.match_key > 0 then
        self:req_quit_match()
    end
    self._gate_net:send_msg(Fight_Pid.req_join_match, {
        match_theme = match_theme,
        teammate_role_ids = teammate_role_ids,
    })
end

function MatchData:req_quit_match(is_force)
    self._gate_net:send_msg(Fight_Pid.req_quit_match, {
        match_key = self.match_key,
        ignore_match_key = is_force and true or false,
    })
end

function MatchData:pull_match_state()
    self._gate_net:send_msg(Fight_Pid.pull_match_state)
end

function MatchData:_on_msg_rsp_join_match(pid, msg)
    log_print("MatchData:_on_msg_rsp_join_match(pid, msg)", pid, msg)
    if Error_None == msg.error_num then
        self:_handle_match_state_pto(msg.match_state)
    end
end

function MatchData:_on_msg_sync_rsp_quit_match(pid, msg)
    log_print("MatchData:_on_msg_sync_rsp_quit_match(pid, msg)", pid, msg)
    self:_handle_match_state_pto(nil)
    self:pull_match_state()
end

function MatchData:_on_msg_sync_match_state(pid, msg)
    log_print("MatchData:_on_msg_sync_match_state(pid, msg)", pid, msg)
    self:_handle_match_state_pto(msg)
end

function MatchData:_handle_match_state_pto(msg)
    local old_match_key = self.match_theme
    local old_state = self.state
    if msg then
        self.match_key = msg.match_key
        self.match_theme = msg.match_theme
        self.state = msg.state
    else
        self.match_key = ""
        self.match_theme = ""
        self.state = Game_Match_Item_State.idle
    end
    if old_match_key ~= self.match_key then
        if #old_match_key > 0 then
            if Game_Match_Item_State.all_over ~= old_state then
                self:fire(Match_Data_Event.match_over, old_match_key)
            end
        end
        if #self.match_key > 0 then
            self:fire(Match_Data_Event.match_start, self.match_key)
            self:fire(Match_Data_Event.match_state_change)
        end
    else
        if #self.match_key then
            if old_state ~= self.state and Game_Match_Item_State.all_over == self.state then
                self:fire(Match_Data_Event.match_over, self.match_key)
            end
            self:fire(Match_Data_Event.match_state_change)
        end
    end
end



