
ServiceBase = ServiceBase or class("ServiceBase")

function ServiceBase:ctor(service_mgr, service_name)
    self.service_mgr = service_mgr
    self.service_name = service_name
    self.server = self.service_mgr.server
    self.curr_state = Service_State.Free
    self.event_binder = nil
    self.timer_proxy = nil
    self.error_num = nil
    self.error_msg = ""
end

function ServiceBase:get_service_name()
    return self.service_name
end

function ServiceBase:get_curr_state()
    return self.curr_state
end

function ServiceBase:to_update_state()
    if Service_State.Started == self.curr_state then
        self.curr_state = Service_State.Update
    end
end

function ServiceBase:get_error()
    return self.error_num, self.error_msg
end

function ServiceBase:init(...)
    self.event_binder = EventBinder:new()
    self.timer_proxy = TimerProxy:new()
    self.curr_state = Service_State.Inited
end

function ServiceBase:start()
    self.curr_state = Service_State.Started
end

function ServiceBase:stop()
    self.curr_state = Service_State.Stopped
end

function ServiceBase:release()
    self.curr_state = Service_State.Released
end

function ServiceBase:on_update()

end


