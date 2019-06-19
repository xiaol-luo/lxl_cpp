
ServiceModuleMgr = ServiceModuleMgr or class("ServiceModuleMgr")

function ServiceModuleMgr:ctor(service)
    self.service = service
    self.event_proxy = self:create_event_proxy()
    self.modules = {}
    self.curr_state = ServiceModuleState.Free
    self.error_num = nil
    self.error_msg = ""
end

function ServiceModuleMgr:create_event_proxy()
    return self.service:create_event_proxy()
end

function ServiceModuleMgr:add_module(module)
    local name = module:get_module_name()
    assert(self.curr_state < ServiceModuleState.Starting)
    assert(not self.modules[name])
    log_debug("ServiceModuleMgr:add_module %s", name)
    self.modules[name] = module
end

function ServiceModuleMgr:start()
    if self.curr_state < ServiceModuleState.Starting then
        self.curr_state = ServiceModuleState.Starting
        self.event_proxy:fire(Service_Module_Event_State_Starting, self)
        for _, m in pairs(self.modules) do
            m:start()
        end
    end
end

function ServiceModuleMgr:stop()
    if self.curr_state >= ServiceModuleState.Starting and self.curr_state < ServiceModuleState.Stopping then
        self.curr_state = ServiceModuleState.Stopping
        self.event_proxy:fire(Service_Module_Event_State_Stopping, self)
        for _, m in pairs(self.modules) do
            m:stop()
        end
    end
end

function ServiceModuleMgr:release()
    self.curr_state = ServiceModuleState.Released
    for _, m in pairs(self.modules) do
        m:release()
    end
    self.event_proxy:fire(Service_Module_Event_State_Released, self)
end

function ServiceModuleMgr:get_error()
    return self.error_num, self.error_msg
end

function ServiceModuleMgr:on_frame()
    if not self.error_num then
        if ServiceModuleState.Update == self.curr_state then
            for _, m in pairs(self.modules) do
                m:on_update()
            end
        end
        if ServiceModuleState.Started == self.curr_state then
            self.curr_state = ServiceModuleState.Update
            self.event_proxy:fire(Service_Module_Event_State_To_Update, self)
            for _, m in pairs(self.modules) do
                m:to_update_state()
            end
        end
        if ServiceModuleState.Starting == self.curr_state then
            local all_started = true
            for _, m in pairs(self.modules) do
                local e_num, e_msg = m:get_error()
                local m_curr_state = m:get_curr_state()
                if e_num then
                    all_started = false
                    self.error_num = e_num
                    self.error_msg = e_msg
                    log_error("ServiceModuleMgr Start Fail! module %s, error_num %s, error_msg %s", m:get_module_name(), self.error_num, self.error_msg)
                    break
                end
                if ServiceModuleState.Started ~= m_curr_state then
                    all_started = false
                    break
                end
            end
            if all_started then
                self.curr_state = ServiceModuleState.Started
                self.event_proxy:fire(Service_Module_Event_State_Started, self)
            end
        end
    end
    if ServiceModuleState.Stopping == self.curr_state then
        local all_stoped = true
        for _, m in pairs(self.modules) do
            local m_curr_state = m:get_curr_state()
            if ServiceModuleState.Stopped ~= m_curr_state then
                all_stoped = false
                break
            end
        end
        if all_stoped then
            self.curr_state = ServiceModuleState.Stopped
            self.event_proxy:fire(Service_Module_Event_State_Stopped, self)
        end
    end
end
