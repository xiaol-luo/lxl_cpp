
ServiceModule = ServiceModule or class("ServiceModule")

function ServiceModule:ctor(module_mgr, module_name)
    self.module_mgr = module_mgr
    self.module_name = module_name
    self.curr_state = ServiceModuleState.Free
    self.event_proxy = nil
    self.error_num = nil
    self.error_msg = ""
end

function ServiceModule:curr_state()
    return self.curr_state
end

function ServiceModule:to_update_state()
    if ServiceModuleState.Started == self.curr_state then
        self.curr_state = ServiceModuleState.Update
    end
end

function ServiceModule:error()
    return self.error_num, self.error_msg
end

function ServiceModule:init(...)
    self.event_proxy = self.module_mgr:create_event_proxy()
    self.curr_state = ServiceModuleState.Inited
end

function ServiceModule:start()
    self.curr_state = ServiceModuleState.Started
end

function ServiceModule:stop()
    self.curr_state = ServiceModuleState.Stopped
end

function ServiceModule:release()
    self.curr_state = ServiceModuleState.Released
end

function ServiceModule:on_update()

end


