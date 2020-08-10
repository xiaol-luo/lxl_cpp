
---@class ServerBase : EventMgr
---@field init_args table<string, string>
---@field init_setting table<string, string>
---@field server_role Server_Role
---@field quit_state Server_Quit_State
ServerBase = ServerBase or class("ServerBase", EventMgr)

function ServerBase:ctor(server_role, init_setting, init_args)
    ServerBase.super.ctor(self)
    self.server_role = string.lower(server_role)
    self.init_args = init_args
    self.init_setting = init_setting
    ---@type Server_Quit_State
    self.quit_state = Server_Quit_State.none
    ---@type EventBinder
    self._event_binder = EventBinder:new()
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
    self._on_frame_tid = nil
end

function ServerBase:init()
    local ret = self:_on_init()
    return ret
end

function ServerBase:start()
    self._on_frame_tid = self._timer_proxy:firm(Functional.make_closure(self._on_frame, self), Const.service_micro_sec_per_frame, Forever_Execute_Timer)
    self:_on_start()
end

function ServerBase:stop()
    if self._on_frame_tid then
        self._timer_proxy:remove(self._on_frame_tid)
        self._on_frame_tid = nil
    end
    self:_on_stop()
end

function ServerBase:release()
    self._event_binder:cancel_all()
    self._timer_proxy:release_all()
    self._on_frame_tid = nil
    self:cancel_all()
end

function ServerBase:try_quit_game()
    native.try_quit_game()
end

function ServerBase:notify_quit_game()
    self:_on_notify_quit_game()
end

function ServerBase:check_can_quit_game()
    local ret = self:_check_can_quit_game()
    return ret
end


function ServerBase:_on_notify_quit_game()
    if Server_Quit_State.none == self.quit_state then
        self.quit_state = Server_Quit_State.quiting
        self:fire(Server_Event.Notify_Quit_Game, self)
        self:stop()
    end
end

function ServerBase:_check_can_quit_game()
    local can_quit = false
    if Service_State.Stopped == self._service_mgr:get_curr_state() then
        can_quit = true
    end
    if can_quit and Server_Quit_State.quiting == self.quit_state then
        self.quit_state = Server_Quit_State.quited
        self:release()
    end
    return can_quit
end

function ServerBase:_on_init()
    return true
end

function ServerBase:_on_start()
end

function ServerBase:_on_stop()
end

function ServerBase:_on_release()
end

function ServerBase:_on_frame()

end


