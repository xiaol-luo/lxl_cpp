
---@class LogicBaseTemplate: EventMgr
---@field logic_mgr ServiceMgrBase
---@field server GameServerBase
LogicBaseTemplate = LogicBaseTemplate or class("LogicBaseTemplate", EventMgr)

function LogicBaseTemplate:ctor(logic_mgr, logic_name)
    LogicBaseTemplate.super.ctor(self)
    self.logic_mgr = logic_mgr
    self._logic_name = logic_name
    ---@type Logic_Mgr_Template_State
    self._curr_state = Logic_Template_State.Free
    self._event_binder = EventBinder:new()
    self._timer_proxy = TimerProxy:new()
    self._error_num = nil
    self._error_msg = ""
end

function LogicBaseTemplate:get_name()
    return self._logic_name
end

function LogicBaseTemplate:get_error()
    return self._error_num, self._error_msg
end

function LogicBaseTemplate:get_curr_state()
    return self._curr_state
end

function LogicBaseTemplate:to_update_state()
    if Logic_Template_State.Started == self._curr_state then
        self._curr_state = Logic_Template_State.Update
    end
end

function LogicBaseTemplate:init(...)
    self._curr_state = Logic_Template_State.Inited
    self:_on_init(...)
end

function LogicBaseTemplate:start()
    self._curr_state = Logic_Template_State.Started
    self:_on_start()
end

function LogicBaseTemplate:stop()
    self._curr_state = Logic_Template_State.Stopped
    self:_on_stop()
end

function LogicBaseTemplate:release()
    self._curr_state = Logic_Template_State.Released
    self._event_binder:release_all()
    self._timer_proxy:release_all()
    self:_on_release()
end

function LogicBaseTemplate:update()
    if Logic_Template_State.Update == self._curr_state then
        self:_on_update()
    end
end

function LogicBaseTemplate:_on_init(...)
    -- override by subclass
end

function LogicBaseTemplate:_on_start()
    -- override by subclass
end

function LogicBaseTemplate:_on_stop()
    -- override by subclass
end

function LogicBaseTemplate:_on_release()
    -- override by subclass
end

function LogicBaseTemplate:_on_update()
    -- override by subclass
end











