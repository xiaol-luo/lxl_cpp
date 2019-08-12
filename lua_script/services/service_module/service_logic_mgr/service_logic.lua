

ServiceLogic = ServiceLogic or class("ServiceLogic")

function ServiceLogic:ctor(logic_mgr, logic_name)
    self.logic_mgr = logic_mgr
    self.logic_name = logic_name
    self.service = self.logic_mgr.service
    self.curr_state = ServiceLogicState.Free
    self.event_proxy = nil
    self.timer_proxy = nil
end

function ServiceLogic:get_logic_name()
    return self.logic_name
end

function ServiceLogic:get_curr_state()
    return self.curr_state
end

function ServiceLogic:init(...)
    self.event_proxy = self.service:create_event_proxy()
    self.timer_proxy = TimerProxy:new()
    self.curr_state = ServiceLogicState.Inited
end

function ServiceLogic:start()
    self.curr_state = ServiceLogicState.Started
end

function ServiceLogic:stop()
    self.curr_state = ServiceLogicState.Stopped
end

function ServiceLogic:release()
    self.curr_state = ServiceLogicState.Released
end


