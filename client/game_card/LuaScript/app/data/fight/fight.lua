
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
    self._gate_net:send_msg(Fight_Pid.req_quit_match, {})
end

function Fight:req_match_state()
    self._gate_net:send_msg(Fight_Pid.req_match_state)
end