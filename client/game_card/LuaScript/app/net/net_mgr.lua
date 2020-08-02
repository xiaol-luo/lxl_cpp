
---@class NetMgr:EventMgr
---@field game_platform_net GamePlatformNetBase
---@field game_login_net GameLoginNetBase
---@field game_gate_net GameGateNetBase
NetMgr = NetMgr or class("NetMgr", EventMgr)

function NetMgr:ctor(_app)
    NetMgr.super.ctor(self)
    ---@type LuaApp
    self._app = _app
    self._pto_parser = self._app.pto_parser
    self.game_platform_net = nil
    self.game_login_net = nil
    self.game_gate_net = nil
    self.fight_net = nil
end

function NetMgr:init()

    if SystemInfo.is_editor then
        self.game_platform_net = GamePlatformNetEditor:new(self)
        self.game_login_net = GameLoginNetEditor:new(self)
        self.game_gate_net = GameGateNetEditor:new(self)
    else

    end

    self.game_platform_net:init()
    self.game_login_net:init()
    self.game_gate_net:init()
end

function NetMgr:game_login()

end

function NetMgr:game_reconnect()

end

function NetMgr:game_logout()

end

function NetMgr:account_logout()

end

function NetMgr:game_is_ready()

end

function NetMgr:_game_reset()

end

function NetMgr:fight_login()

end

function NetMgr:fight_reconnect()

end

function NetMgr:fight_logout()

end

function NetMgr:fight_is_ready()

end

function NetMgr:_fight_reset()

end

function NetMgr:release()
    self._game_platform_net:release()
    self._game_login_net:release()
    self._game_gate_net:release()
    self:cancel_all()
end


