
---@class GamePlatformNetBase:EventMgr
GamePlatformNetBase = class("GamePlatformNetBase", EventMgr)

function GamePlatformNetBase:ctor(net_mgr)
    GamePlatformNetBase.super.ctor(self)
    ---@type NetMgr
    self._net_mgr = net_mgr
    ---@type LuaApp
    self._app = self._net_mgr.app
end

function GamePlatformNetBase:init()
    self:_on_init()
end

function GamePlatformNetBase:release()
    self:_on_release()
    self:cancel_all()
end

function GamePlatformNetBase:_on_init()

end

function GamePlatformNetBase:_on_release()

end

function GamePlatformNetBase:login()

end

function GamePlatformNetBase:logout()

end

function GamePlatformNetBase:is_ready()

end

function GamePlatformNetBase:get_error_msg()

end

function GamePlatformNetBase:notify_ready_change()
    self._net_mgr:fire(Game_Net_Event.platform_ready_change, self:is_ready(), self:get_error_msg())
end

function GamePlatformNetBase:get_platform_name()

end

function GamePlatformNetBase:get_app_id()

end

function GamePlatformNetBase:get_account_id()

end

function GamePlatformNetBase:get_token()

end



