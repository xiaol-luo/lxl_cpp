
---@class ServiceBase: EventMgr
---@field service_mgr ServiceMgrBase
---@field server ServerBase
ServiceBase = ServiceBase or class("ServiceBase", EventMgr)

function ServiceBase:ctor(service_mgr, service_name)
    ServiceBase.super.ctor(self)
    self.service_mgr = service_mgr
    self.server = self.service_mgr.server
    self._service_name = service_name
    self._curr_state = Service_State.Free
    self._event_binder = EventBinder:new()
    self._timer_proxy = TimerProxy:new()
    self._error_num = nil
    self._error_msg = ""
end

function ServiceBase:get_service_name()
    return self._service_name
end

function ServiceBase:get_error()
    return self._error_num, self._error_msg
end

function ServiceBase:get_curr_state()
    return self._curr_state
end

function ServiceBase:to_update_state()
    if Service_State.Started == self._curr_state then
        self._curr_state = Service_State.Update
    end
end

function ServiceBase:init(...)
    self._curr_state = Service_State.Inited
    self:_on_init(...)
end

function ServiceBase:start()
    self._curr_state = Service_State.Started
    self:_on_start()
end

function ServiceBase:stop()
    self._curr_state = Service_State.Stopped
    self:_on_stop()
end

function ServiceBase:release()
    self._curr_state = Service_State.Released
    self._event_binder:release_all()
    self._timer_proxy:release_all()
    self:_on_release()
end

function ServiceBase:update()
    if Service_State.Update == self._curr_state then
        self:_on_update()
    end
end

function ServiceBase:_on_init(...)

end

function ServiceBase:_on_start()

end

function ServiceBase:_on_stop()

end

function ServiceBase:_on_release()

end

function ServiceBase:_on_update()

end


