
---@class GameLoginNetEditor:GameLoginNetBase
GameLoginNetEditor = class("GameLoginNetEditor", GameLoginNetBase)

function GameLoginNetEditor:ctor(net_mgr)
    GameLoginNetEditor.super.ctor(self, net_mgr)
    self._is_ready = false
    self._user_id = nil
    self._gate_hosts = nil
    self._error_msg = ""
    self._auth_sn = nil
end

function GameLoginNetEditor:_on_init()

end

function GameLoginNetEditor:_on_release()

end

function GameLoginNetEditor:login()
    if self._gate_hosts and self._user_id then
        self._is_ready = true
        self._auth_sn = string.format("%9d", math.random(1, 999999900))
        self:notify_login_done()
    end
end

function GameLoginNetEditor:logout()
    self._is_ready = false
    self._user_id = nil
    self._gate_hosts = nil
end

function GameLoginNetEditor:is_ready()
    return self._is_ready
end

function GameLoginNetEditor:get_error_msg()
    return self._error_msg
end

function GameLoginNetEditor:get_user_id()
    return self._user_id
end

function GameLoginNetEditor:get_gate_hosts()
    return self._gate_hosts
end

function GameLoginNetEditor:get_auth_sn()
    return self._auth_sn
end







