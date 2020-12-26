
---@class FightData:DataBase
FightData = FightData or class("Fight", DataBase)

assert(DataBase)

function FightData:ctor(data_mgr)
    FightData.super.ctor(self, data_mgr, "fight")
    ---@type GameGateNetBase
    self._gate_net = self._app.net_mgr.game_gate_net
    ---@type FightNetBase
    self._fight_net = self._app.net_mgr.fight_net

    self.fight_data = {}
end

function FightData:_on_init()
    Fight.super._on_init(self)

    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_bind_fight, Functional.make_closure(self._on_msg_rsp_bind_fight, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.sync_fight_state_two_dice, Functional.make_closure(self._on_msg_sync_fight_state_two_dice, self))
    self._event_binder:bind(self._app.net_mgr, Fight_Pid.rsp_fight_opera, Functional.make_closure(self._on_msg_rsp_fight_opera, self))

    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.fight_connect_done, Functional.make_closure(self._on_event_fight_net_connect_done, self))
end

function FightData:_on_release()
    Fight.super._on_release(self)
end

---@param match_theme Match_Theme
---@param teammate_role_ids table<number, number>
function MatchData:req_bind_fight(match_theme, teammate_role_ids)
    self._gate_net:send_msg(Fight_Pid.req_bind_fight, {

    })
end

function MatchData:pull_fight_state()
    self._gate_net:send_msg(Fight_Pid.pull_fight_state, {

    })
end

function MatchData:req_fight_opera()
    self._gate_net:send_msg(Fight_Pid.req_fight_opera, {

    })
end

function FightData:_on_msg_rsp_bind_fight(pid, msg)
    log_print("FightData:_on_msg_rsp_bind_fight(pid, msg)", pid, msg)
end

function FightData:_on_msg_sync_fight_state_two_dice(pid, msg)
    log_print("FightData:_on_msg_sync_fight_state_two_dice(pid, msg)", pid, msg)
end

function FightData:_on_msg_rsp_fight_opera(pid, msg)
    log_print("FightData:_on_msg_rsp_fight_opera(pid, msg)", pid, msg)
end

function FightData:_on_event_fight_net_connect_done(is_ready, error_msg)
    log_print("FightData:_on_fight_net_connect_done", is_ready, error_msg)
    if is_ready then
        self._fight_net:send_msg(Fight_Pid.req_bind_fight, {
            fight_key = self.fight_data.fight_key,
            token = self.fight_data.fight_token,
            role_id = self._data_mgr.main_role:get_role_id(),
        })
    else

    end
end


