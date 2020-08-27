
---@class GameLoginNetBase:EventMgr
GameLoginNetBase = class("GameLoginNetBase", EventMgr)

function GameLoginNetBase:ctor(net_mgr)
    GameLoginNetBase.super.ctor(self)
    ---@type NetMgr
    self._net_mgr = net_mgr
    ---@type LuaApp
    self._app = self._net_mgr.app
end

function GameLoginNetBase:init()
    self:_on_init()
end

function GameLoginNetBase:release()
    self:_on_release()
    self:cancel_all()
end

function GameLoginNetBase:_on_init()

end

function GameLoginNetBase:_on_release()

end

function GameLoginNetBase:login()

end

function GameLoginNetBase:logout()

end

function GameLoginNetBase:is_ready()

end

function GameLoginNetBase:get_error_msg()

end

function GameLoginNetBase:notify_ready_change()
    self._net_mgr:fire(Game_Net_Event.game_login_ready_change, self:is_ready(), self:get_error_msg())
end

function GameLoginNetBase:notify_login_done()
    self._net_mgr:fire(Game_Net_Event.platform_login_done, self:is_ready(), self:get_error_msg())
end

function GameLoginNetBase:notify_login_start()
    self._net_mgr:fire(Game_Net_Event.platform_login_start)
end

-- get fields

function GameLoginNetBase:get_user_id()

end

function GameLoginNetBase:get_token()

end

function GameLoginNetBase:get_auth_host()

end





