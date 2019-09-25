ServiceBase = ServiceBase or class("ServiceBase")

local QuitState = {
    none = 1,
    quiting = 2,
    quited = 3,
}

function ServiceBase:ctor()
    self.timer_proxy = nil
    self.event_mgr = nil
    self.event_proxy = nil
    self.module_mgr = nil
    self.is_quiting = false
    self.is_quited = false
    self.quit_state = QuitState.none
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
end


function ServiceBase:on_frame()
    self.module_mgr:on_frame()
    CoroutineExMgr.on_frame()
    local error_num, error_msg = self.module_mgr:get_error()
    if error_num and QuitState.none == self.quit_state then
        native.try_quit_game()
        assert(error_num, error_msg)
    end
end

function ServiceBase:OnNotifyQuitGame()
    if QuitState.none == self.quit_state then
        self.quit_state = QuitState.quiting
    end
    self.event_proxy:fire(Service_Base_Event_Notify_Quit_Game, self)
    self:stop()
end

function ServiceBase:CheckCanQuitGame()
    -- log_debug("ServiceBase:CheckCanQuitGame 1")
    local can_quit = false
    if not self.module_mgr then
        can_quit = true
    end
    if self.module_mgr and ServiceModuleState.Stopped == self.module_mgr:get_curr_state() then
        log_debug("ServiceBase:CheckCanQuitGame true")
        can_quit = true
    end
    if can_quit and QuitState.quiting == self.quit_state then
        self.quit_state = QuitState.quited
        self.module_mgr:release()
        self.timer_proxy:release_all()
        CoroutineExMgr.stop()
    else
        -- self.module_mgr:print_module_state()
    end
    return can_quit
end

