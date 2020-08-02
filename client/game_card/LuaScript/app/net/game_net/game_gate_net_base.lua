---@class GameGateNetBase:EventMgr
GameGateNetBase = class("GameGateNetBase", EventMgr)

function GameGateNetBase:ctor(net_mgr)
    GameGateNetBase.super.ctor(self)
    ---@type NetMgr
    self._net_mgr = net_mgr
    ---@type LuaApp
    self._app = self._net_mgr.app
    ---@type ProtoParser
    self._pto_parser = self._net_mgr._pto_parser
end

function GameGateNetBase:init()
    self:_on_init()
end

function GameGateNetBase:release()
    self:_on_release()
    self:cancel_all()
end

function GameGateNetBase:_on_init()

end

function GameGateNetBase:_on_release()

end

function GameGateNetBase:connect()

end

function GameGateNetBase:disconnect()

end

function GameGateNetBase:reconnect()

end

function GameGateNetBase:get_error_msg()

end

function GameGateNetBase:is_ready()

end

function GameGateNetBase:is_connecting()

end

function GameGateNetBase:get_error_msg()

end

function GameGateNetBase:notify_connect_done()
    self._net_mgr:fire(Game_Net_Event.gate_connect_done, self:is_ready(), self:get_error_msg())
end

function GameGateNetBase:notify_ready_change()
    self._net_mgr:fire(Game_Net_Event.gate_connect_ready_change, self, self:is_ready())
end

function GameGateNetBase:send_msg(pid, msg)

end




