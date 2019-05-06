
ServiceModuleMgr = ServiceModuleMgr or class("ServiceModuleMgr")

function ServiceModuleMgr:ctor(service)
    self.service = service
    self.modules = {}
    self.curr_state = ServiceModuleState.Free
    self.error_num = nil
    self.error_msg = ""
end

function ServiceModuleMgr:create_event_proxy()
    return self.service:create_event_proxy()
end

function ServiceModuleMgr:add_module(name, module)
    assert(self.curr_state < ServiceModuleState.Starting)
    assert(not self.modules[name])
    self.modules[name] = module
end

function ServiceModuleMgr:start()
    if self.curr_state < ServiceModuleState.Starting then
        self.curr_state = ServiceModuleState.Starting
        for _, m in pairs(self.modules) do
            m:start()
        end
    end
end

function ServiceModuleMgr:stop()
    if self.curr_state >= ServiceModuleState.Starting and self.curr_state < ServiceModuleState.Stopping then
        self.curr_state = ServiceModuleState.Stopping
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
            for _, m in pairs(self.modules) do
                m:to_update_state()
            end
        end
        if ServiceModuleState.Starting == self.curr_state then
            local all_started = true
            for _, m in pairs(self.modules) do
                local e_num, e_msg = m:error()
                local m_curr_state = m:curr_state()
                if e_num then
                    all_started = false
                    self.error_num = e_num
                    self.error_msg = e_msg
                    break
                end
                if ServiceModuleState.Started ~= m_curr_state then
                    all_started = false
                    break
                end
            end
            if all_started then
                self.curr_state = ServiceModuleState.Started
            end
        end
    end
    if ServiceModuleState.Stopping == self.curr_state then
        local all_stoped = true
        for _, m in pairs(self.modules) do
            local e_num, e_msg = m:error()
            local m_curr_state = m:curr_state()
            if ServiceModuleState.Stopped ~= m_curr_state and not e_num then
                all_stoped = false
                break
            end
        end
        if all_stoped then
            self.curr_state = ServiceModuleState.Stopped
        end
    end
end
