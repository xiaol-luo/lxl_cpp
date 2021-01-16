
---@class ExampleServiceBase: EventMgr
---@field service_mgr ServiceMgrBase
---@field server GameServerBase
ExampleServiceBase = ExampleServiceBase or class("ExampleServiceBase", EventMgr)

function ExampleServiceBase:ctor(service_mgr, service_name)
    ExampleServiceBase.super.ctor(self)
    self.service_mgr = service_mgr
    self._service_name = service_name
    ---@type Example_Service_Mgr_State
    self._curr_state = Example_Service_State.Free
    self._event_binder = EventBinder:new()
    self._timer_proxy = TimerProxy:new()
    self._error_num = nil
    self._error_msg = ""
end

function ExampleServiceBase:get_name()
    return self._service_name
end

function ExampleServiceBase:get_error()
    return self._error_num, self._error_msg
end

function ExampleServiceBase:get_curr_state()
    return self._curr_state
end

function ExampleServiceBase:to_update_state()
    if Example_Service_State.Started == self._curr_state then
        self._curr_state = Example_Service_State.Update
    end
end

function ExampleServiceBase:init(...)
    self._curr_state = Example_Service_State.Inited
    self:_on_init(...)
end

function ExampleServiceBase:start()
    self._curr_state = Example_Service_State.Started
    self:_on_start()
end

function ExampleServiceBase:stop()
    self._curr_state = Example_Service_State.Stopped
    self:_on_stop()
end

function ExampleServiceBase:release()
    self._curr_state = Example_Service_State.Released
    self._event_binder:release_all()
    self._timer_proxy:release_all()
    self:_on_release()
end

function ExampleServiceBase:update()
    if Example_Service_State.Update == self._curr_state then
        self:_on_update()
    end
end

function ExampleServiceBase:_on_init(...)
    -- override by subclass
end

function ExampleServiceBase:_on_start()
    -- override by subclass
end

function ExampleServiceBase:_on_stop()
    -- override by subclass
end

function ExampleServiceBase:_on_release()
    -- override by subclass
end

function ExampleServiceBase:_on_update()
    -- override by subclass
end











