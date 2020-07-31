---@class GameGateNetBase:EventMgr
GameGateNetBase = class("GameGateNetBase", EventMgr)

function GameGateNetBase:ctor(net_mgr)
    GameGateNetBase.super.ctor(self)
    self.net_mgr = net_mgr
end

function GameGateNetBase:connect()

end

function GameGateNetBase:disconnect()

end

function GameGateNetBase:reconnect()

end

function GameGateNetBase:get_error_msg()

end

function GameLoginNetBase:is_ready()

end

function GameLoginNetBase:get_error_msg()

end

function GameGateNetBase:notify_connect_done()
    self.net_mgr:fire(Game_Net_Event.gate_connect_done, self, self:is_ready(), self:get_error_msg())
end




