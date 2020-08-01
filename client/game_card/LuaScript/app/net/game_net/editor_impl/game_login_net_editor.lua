
---@class GameLoginNetEditor:EventMgr
GameLoginNetEditor = class("GameLoginNetEditor", GameLoginNetBase)

function GameLoginNetEditor:ctor(net_mgr)
    GameLoginNetEditor.super.ctor(self, net_mgr)
end

function GameLoginNetEditor:_on_init()

end

function GameLoginNetEditor:_on_release()

end

function GameLoginNetEditor:login()

end

function GameLoginNetEditor:logout()

end

function GameLoginNetEditor:is_ready()

end

function GameLoginNetEditor:get_error_msg()

end

function GameLoginNetEditor:notify_login_done()
    self.net_mgr:fire(Game_Net_Event.platform_login_done, self, self:is_ready(), self:get_error_msg())
end


function GameLoginNetEditor:get_gate_ip()

end

function GameLoginNetEditor:get_gate_port()

end

function GameLoginNetEditor:get_user_id()

end

function GameLoginNetEditor:get_auth_ip()

end

function GameLoginNetEditor:get_auth_port()

end

function GameLoginNetEditor:_get_login_ip()

end

function GameLoginNetEditor:_get_login_port()

end




