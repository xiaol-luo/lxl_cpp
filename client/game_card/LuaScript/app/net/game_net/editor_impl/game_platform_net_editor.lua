
---@class GamePlatformNetEditor:GamePlatformNetBase
GamePlatformNetEditor = class("GamePlatformNetEditor", GamePlatformNetBase)

function GamePlatformNetEditor:ctor(net_mgr)
    GamePlatformNetEditor.super.ctor(self, net_mgr)
    self._timer_proxy = TimerProxy:new()
    self._is_ready = false
    self._error_msg = nil
    self._app_id = "test_app_id"
    self._platform_name = "platform_for_test"
    self._account_id = nil
    self._platform_ip = nil
    self._platform_port = nil
    self._token = nil
    self._token_timestamp = nil
end

function GamePlatformNetEditor:_on_init()

end

function GamePlatformNetEditor:_on_release()
    self._timer_proxy:release_all()
end

function GamePlatformNetEditor:login()
    self:logout()
    self._error_msg = nil
    local get_rul = string.format("http://%s:%s/login_platform?platform_account_id=%s&app_id=%s&password=%s",
            self._platform_ip, self._platform_port, self._account_id, self._app_id, "test_test")
    log_print("request url ", get_rul)
    UnityHttpClient.get(get_rul, Functional.make_closure(self._on_http_rsp_login, self))
    self:notify_login_start()
end

function GamePlatformNetEditor:_on_http_rsp_login(http_error, rspContent, heads_map)
    -- log_print("GamePlatformNetEditor:_on_http_rsp_login", http_error, rspContent)
    if http_error then
        log_print("GamePlatformNetEditor http_error is ", http_error)
        self:_set_is_ready(false, http_error)
        return
    end
    local http_ret = lua_json.decode(rspContent)
    if Error_None ~= http_ret.error_num then
        log_print("GamePlatformNetEditor http_ret.error_num is", http_ret.error_num, http_ret.error_msg)
        self:_set_is_ready(false, http_ret.error_msg)
        return
    end
    self._token = http_ret.token
    self._token_timestamp = http_ret.timestamp
    self:_set_is_ready(true)
    self:notify_login_done()
end

function GamePlatformNetEditor:logout()
    self._is_ready = false
    self:_set_is_ready(false)
end

function GamePlatformNetEditor:_set_is_ready(is_ready, error_msg)
    local old_is_ready = self._is_ready
    self._is_ready = is_ready
    self._error_msg = error_msg
    if old_is_ready ~= self._is_ready then
        self:notify_ready_change()
    end
end

function GamePlatformNetEditor:is_ready()
    return self._is_ready
end

function GamePlatformNetEditor:get_error_msg()
    return self._error_msg
end

-- get fields

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
    return self._token, self._token_timestamp
end




