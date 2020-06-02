
---@class ServiceMgrBase : EventMgr
ServiceMgrBase = ServiceMgrBase or class("ServiceMgrBase", EventMgr)

function ServiceMgrBase:ctor(server)
    ServiceMgrBase.super.ctor(self)
    self.server = server
    self.services = {}
    ---@type Service_State
    self.curr_state = Service_State.Free
    self.error_num = nil
    self.error_msg = ""
end

function ServiceMgrBase:create_event_proxy()
    return self.service:create_event_proxy()
end

function ServiceMgrBase:add_service(service)
    local name = service:get_service_name()
    assert(self.curr_state < Service_State.Starting)
    self.server:_set_as_field(name, service)
    assert(not self.services[name])
    self.services[name] = service
    log_debug("ServiceMgrBase:add_service %s", name)
end

function ServiceMgrBase:init()
    if Service_State.Free ~= self.curr_state then
        return false
    end
    self.curr_state = Service_State.Inited

    local hotfix_svc = HotfixService:new(self, Service_Name.hotfix)
    hotfix_svc:init("hotifx_dir")
    self:add_service(hotfix_svc)

    local discovery = DiscoveryService:new(self, Service_Name.discovery)
    discovery:init()
    self:add_service(discovery)

    local peer_net_svc = PeerNetService:new(self, Service_Name.peer_net)
    peer_net_svc:init()
    self:add_service(peer_net_svc)

    local rpc_svc = RpcService:new(self, Service_Name.rpc)
    rpc_svc:init()
    self:add_service(rpc_svc)

    local zone_setting_svc = ZoneSettingService:new(self, Service_Name.zone_setting)
    zone_setting_svc:init()
    self:add_service(zone_setting_svc)

    local ret = self:_on_init()
    return ret
end

function ServiceMgrBase:_on_init()
    assert(false,"should not reach here")
end

function ServiceMgrBase:start()
    if self.curr_state < Service_State.Starting then
        self.curr_state = Service_State.Starting
        self:fire(Service_Event.State_Starting, self)
        for _, svc in pairs(self.services) do
            svc:start()
        end
    end
end

function ServiceMgrBase:stop()
    if self.curr_state >= Service_State.Starting and self.curr_state < Service_State.Stopping then
        self.curr_state = Service_State.Stopping
        self:fire(Service_Event.State_Stopping, self)
        for _, svc in pairs(self.services) do
            svc:stop()
        end
    end
end

function ServiceMgrBase:release()
    if Service_State.Released == self.curr_state then
        return
    end
    self.curr_state = Service_State.Released
    for _, svc in pairs(self.services) do
        svc:release()
    end
    self:fire(Service_Event.State_Released, self)
end

function ServiceMgrBase:get_error()
    return self.error_num, self.error_msg
end

function ServiceMgrBase:get_curr_state()
    return self.curr_state
end

function ServiceMgrBase:print_service_state()
    for k, v in pairs(self.services) do
        log_debug("service state: %s is %s", k, v:get_curr_state())
    end
end

function ServiceMgrBase:on_frame()
    if not self.error_num then
        if Service_State.Update == self.curr_state then
            for _, m in pairs(self.services) do
                m:update()
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
                    log_error("ServiceMgrBase Start Fail! service=%s, error_num=%s, error_msg=%s", m:get_service_name(), self.error_num, self.error_msg)
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
