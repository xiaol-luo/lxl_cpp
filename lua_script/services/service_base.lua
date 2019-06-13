ServiceBase = ServiceBase or class("ServiceBase")

function ServiceBase:ctor()
    self.timer_proxy = nil
    self.event_mgr = nil
    self.event_proxy = nil
    self.module_mgr = nil
end

function ServiceBase:init()
    self.event_mgr = EventMgr:new()
    self.event_proxy = self:create_event_proxy()
    self.timer_proxy = TimerProxy:new()
    self.module_mgr = ServiceModuleMgr:new(self)
    self:setup_modules()
    self.event_proxy:fire(Service_Base_Event_Inited, self)
end

function ServiceBase:setup_modules()
    assert(false, "should not reach here")
end

function ServiceBase:create_event_proxy()
    local ret = EventProxy:new(self.event_mgr)
    return ret
end

function ServiceBase:start()
    self.event_proxy:fire(Service_Base_Event_Start, self)
    CoroutineExMgr.start()
    self.module_mgr:start()
    self.timer_proxy:firm(Functional.make_closure(self.on_frame, self),
            SERVICE_MICRO_SEC_PER_FRAME, -1)
end

function ServiceBase:stop()
    self.event_proxy:fire(Service_Base_Event_Stop, self)
    self.module_mgr:stop()
    self.timer_proxy:release_all()
    self.module_mgr:release()
    CoroutineExMgr.stop()
end


function ServiceBase:on_frame()
    self.module_mgr:on_frame()
    CoroutineExMgr.on_frame()
end

function ServiceBase:OnNotifyQuitGame()
    self.event_proxy:fire(Service_Base_Event_Notify_Quit_Game, self)
    self:stop()
end

function ServiceBase:CheckCanQuitGame()
    return true
end

