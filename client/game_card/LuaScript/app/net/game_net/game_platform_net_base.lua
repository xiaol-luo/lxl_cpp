
---@class GamePlatformNetBase:EventMgr
GamePlatformNetBase = class("GamePlatformNetBase", EventMgr)

function GamePlatformNetBase:ctor(net_mgr)
    GamePlatformNetBase.super.ctor(self)
    self.net_mgr = net_mgr
end

function GamePlatformNetBase:login()

end

function GamePlatformNetBase:logout()

end

function GamePlatformNetBase:is_ready()

end

function GamePlatformNetBase:get_error_msg()

end

function GamePlatformNetBase:notify_login_done()
    self.net_mgr:fire(Game_Net_Event.platform_login_done, self, self:is_ready(), self:get_error_msg())
end

function GamePlatformNetBase:get_platform_name()

end

function GamePlatformNetBase:get_app_id()

end

function GamePlatformNetBase:get_account_id()

end

function GamePlatformNetBase:get_token()

end



