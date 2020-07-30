
---@class NetMgr:EventMgr
NetMgr = NetMgr or class("NetMgr", EventMgr)

function NetMgr:ctor(_app)
    NetMgr.super.ctor(self)
    self._app = _app
    self._game_platform_net = nil
    self._game_login_net = nil
    self._game_gate_net = nil
    self._fight_net = nil
end

function NetMgr:init()

end

function NetMgr:login_game()

end

function NetMgr:reconnect_game()

end

function NetMgr:logout_game()

end

function NetMgr:login_fight()

end

function NetMgr:reconnect_fight()

end

function NetMgr:logout_fight()

end

