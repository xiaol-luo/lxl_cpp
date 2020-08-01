---@class GameGateNetBase:EventMgr
GameGateNetBase = class("GameGateNetBase", EventMgr)

function GameGateNetBase:ctor(net_mgr)
    GameGateNetBase.super.ctor(self)
    self.net_mgr = net_mgr
    self.app = self.net_mgr.app
end

function GameGateNetBase:init()
    self:_on_init()
end

function GameGateNetBase:release()
    self:_on_release()
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

function GameLoginNetBase:is_ready()

end

function GameLoginNetBase:get_error_msg()

end

function GameGateNetBase:notify_connect_done()
    self.net_mgr:fire(Game_Net_Event.gate_connect_done, self, self:is_ready(), self:get_error_msg())
end




