
---@class GameLoginNetBase:EventMgr
GameLoginNetBase = class("GameLoginNetBase", EventMgr)

function GameLoginNetBase:ctor(net_mgr)
    GameLoginNetBase.super.ctor(self)
    self.net_mgr = net_mgr
end

function GameLoginNetBase:login()

end

function GameLoginNetBase:logout()

end

function GameLoginNetBase:is_ready()

end

function GameLoginNetBase:get_error_msg()

end

function GameLoginNetBase:notify_login_done()
    self.net_mgr:fire(Game_Net_Event.platform_login_done, self, self:is_ready(), self:get_error_msg())
end


function GameLoginNetBase:get_gate_ip()

end

function GameLoginNetBase:get_gate_port()

end

function GameLoginNetBase:get_user_id()

end

function GameLoginNetBase:get_auth_ip()

end

function GameLoginNetBase:get_auth_port()

end

function GameLoginNetBase:_get_login_ip()

end

function GameLoginNetBase:_get_login_port()

end




