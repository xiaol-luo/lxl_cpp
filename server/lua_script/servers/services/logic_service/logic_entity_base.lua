
---@class LogicEntityBase:EventMgr
---@field server GameServerBase
---@field logics LogicServiceBase
LogicEntityBase = LogicEntityBase or class("LogicEntityBase", EventMgr)

function LogicEntityBase:ctor(logics, logic_name)
    LogicEntityBase.super.ctor(self)
    self.logics = logics
    self._logic_name = logic_name
    self.server = self.logics.server
    self._curr_state = Logic_Entity_State.Free
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
    ---@type EventBinder
    self._event_binder = EventBinder:new()
end

function LogicEntityBase:set_error(error_num, error_msg)
    self.logics._error_num = error_num
    self.logics._error_msg = error_msg
end

function LogicEntityBase:get_name()
    return self._logic_name
end

function LogicEntityBase:get_curr_state()
    return self._curr_state
end

function LogicEntityBase:init(...)
    self._curr_state = Logic_Entity_State.Inited
    self:_on_init(...)
end

function LogicEntityBase:start()
    self._curr_state = Logic_Entity_State.Started
    self:_on_start()
end

function LogicEntityBase:stop()
    self._curr_state = Logic_Entity_State.Stopped
    self:_on_stop()
end

function LogicEntityBase:release()
    self._curr_state = Logic_Entity_State.Released
    self._timer_proxy:release_all()
    self._event_binder:release_all()
    self:_on_release()
    self:cancel_all()
end

function LogicEntityBase:update()
    self:_on_update()
end

function LogicEntityBase:_on_init(...)

end

function LogicEntityBase:_on_start()

end

function LogicEntityBase:_on_stop()

end

function LogicEntityBase:_on_release()

end

function LogicEntityBase:_on_update()

end


