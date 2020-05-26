
---@class ServiceMgr : EventMgr
ServiceMgr = ServiceMgr or class("ServiceMgr", EventMgr)

function ServiceMgr:ctor(server)
    self.server = server
    self.services = {}
    self.curr_state = Service_State.Free
    self.error_num = nil
    self.error_msg = ""
end

function ServiceMgr:create_event_proxy()
    return self.service:create_event_proxy()
end

function ServiceMgr:add_service(module)
    local name = module:get_service_name()
    assert(self.curr_state < Service_State.Starting)
    assert(not self.services[name])
    assert(not self.server[name])
    self.services[name] = module
    self.server[name] = module
    log_debug("ServiceMgr:add_service %s", name)
end

function ServiceMgr:init()
    if Service_State.Free ~= self.curr_state then
        return
    end
    self.curr_state = Service_State.Inited
end

function ServiceMgr:start()
    if self.curr_state < Service_State.Starting then
        self.curr_state = Service_State.Starting
        self:fire(Service_Event.State_Starting, self)
        for _, svc in pairs(self.services) do
            svc:start()
        end
    end
end

function ServiceMgr:stop()
    if self.curr_state >= Service_State.Starting and self.curr_state < Service_State.Stopping then
        self.curr_state = Service_State.Stopping
        self:fire(Service_Event.State_Stopping, self)
        for _, svc in pairs(self.services) do
            svc:stop()
        end
    end
end

function ServiceMgr:release()
    self.curr_state = Service_State.Released
    for _, svc in pairs(self.services) do
        svc:release()
    end
    self:fire(Service_Event.State_Released, self)
end

function ServiceMgr:get_error()
    return self.error_num, self.error_msg
end

function ServiceMgr:get_curr_state()
    return self.curr_state
end

function ServiceMgr:print_module_state()
    for k, v in pairs(self.services) do
        log_debug("module state: %s is %s", k, v:get_curr_state())
    end
end

function ServiceMgr:on_frame()
    if not self.error_num then
        if Service_State.Update == self.curr_state then
            for _, m in pairs(self.services) do
                m:on_update()
            end
        end
        if Service_State.Started == self.curr_state then
            self.curr_state = Service_State.Update
            self:fire(Service_Event.State_To_Update, self)
            for _, m in pairs(self.services) do
                m:to_update_state()
            end
        end
        if Service_State.Starting == self.curr_state then
            local all_started = true
            for _, m in pairs(self.services) do
                local e_num, e_msg = m:get_error()
                local m_curr_state = m:get_curr_state()
                if e_num then
                    all_started = false
                    self.error_num = e_num
                    self.error_msg = e_msg
                    log_error("ServiceMgr Start Fail! module %s, error_num %s, error_msg %s", m:get_module_name(), self.error_num, self.error_msg)
                    break
                end
                if Service_State.Started ~= m_curr_state then
                    all_started = false
                    break
                end
            end
            if all_started then
                self.curr_state = Service_State.Started
                self:fire(Service_Event.State_Started, self)
            end
        end
    end
    if Service_State.Stopping == self.curr_state then
        local all_stoped = true
        for _, m in pairs(self.services) do
            local m_curr_state = m:get_curr_state()
            if Service_State.Stopped ~= m_curr_state then
                all_stoped = false
                break
            end
        end
        if all_stoped then
            self.curr_state = Service_State.Stopped
            self:fire(Service_Event.State_Stopped, self)
        end
    end
end
