
---@class GameGateNetEditor:EventMgr
GameGateNetEditor = class("GameGateNetEditor", GameGateNetBase)

function GameGateNetEditor:ctor(net_mgr)
    GameGateNetEditor.super.ctor(self, net_mgr)
end

function GameGateNetEditor:_on_init()

end

function GameGateNetEditor:_on_release()

end

function GameGateNetEditor:connect()

end

function GameGateNetEditor:disconnect()

end

function GameGateNetEditor:reconnect()

end

function GameGateNetEditor:get_error_msg()

end

function GameLoginNetBase:is_ready()

end

function GameLoginNetBase:get_error_msg()

end

function GameGateNetEditor:notify_connect_done()
    self.net_mgr:fire(Game_Net_Event.gate_connect_done, self, self:is_ready(), self:get_error_msg())
end




