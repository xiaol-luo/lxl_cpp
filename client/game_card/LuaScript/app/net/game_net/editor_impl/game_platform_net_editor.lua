
---@class GamePlatformNetEditor:EventMgr
GamePlatformNetEditor = class("GamePlatformNetEditor", GamePlatformNetBase)

function GamePlatformNetEditor:ctor(net_mgr)
    GamePlatformNetEditor.super.ctor(self, net_mgr)
    self._timer_proxy = TimerProxy:new()
    self._is_ready = false
    self._app_id = 1
    self._platform_name = "platform_for_test"
    self._account_id = nil
    self._token = nil
end

function GamePlatformNetEditor:_on_init()

end

function GamePlatformNetEditor:_on_release()
    self._timer_proxy:release_all()
end

function GamePlatformNetEditor:login()
    self:logout()
    self._is_ready = false
    if is_number(self._account_id) then
        self._is_ready = true
    end
    self._token = string.format("%9d", math.random(1, 999999999))
    -- self._timer_proxy:delay(Functional.make_closure(self.notify_login_done, self), 1)
end

function GamePlatformNetEditor:logout()
    self._account_id = nil
    self._token = nil
    self._is_ready = false
end

function GamePlatformNetEditor:is_ready()
    return self._is_ready
end

function GamePlatformNetEditor:get_error_msg()
    return ""
end

function GamePlatformNetEditor:notify_login_done()
    self.net_mgr:fire(Game_Net_Event.platform_login_done, self, self:is_ready(), self:get_error_msg())
end

function GamePlatformNetEditor:get_platform_name()
    return self._platform_name
end

function GamePlatformNetEditor:get_app_id()
    return self._app_id
end

function GamePlatformNetEditor:get_account_id()
    return self._account_id
end

function GamePlatformNetEditor:get_token()
    return tostring(math.random(1, 999999999))
end



