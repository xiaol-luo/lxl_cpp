
---@class RobotBase : EventMgr
---@field init_args table<string, string>
---@field init_setting table<string, string>
---@field robot_role Robot_Role
---@field pto_parser Proto
RobotBase = RobotBase or class("RobotBase", EventMgr)

function RobotBase:ctor(robot_role, init_setting, init_args)
    RobotBase.super.ctor(self)
    self.robot_role = string.lower(robot_role)
    self.init_setting = init_setting
    self.init_args = init_args
    ---@type EventBinder
    self._event_binder = EventBinder:new()
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
    ---@type Robot_Quit_State
    self._quit_state = Robot_Quit_State.none
    self.pto_parser = ProtoParser:new()
end

function RobotBase:init()
    local ret = self:_on_init()
    return ret
end

function RobotBase:start()
    self:_on_start()
end

function RobotBase:stop()
    self:_on_stop()
end

function RobotBase:notify_quit()
    self:_on_notify_quit()
end

function RobotBase:check_can_quit()
    local ret = self:_check_can_quit()
    return ret
end

function RobotBase:release()
    self:_on_release()
end

function RobotBase:_on_init()
    self.pto_parser:add_search_dirs({ path.combine(self.init_args[Arg_Name.data_dir], "proto")  })
    return true
end

function RobotBase:_on_start()
    self._timer_proxy:firm(Functional.make_closure(self._on_frame, self), 1000 / 25, Forever_Execute_Timer)
    CoroutineExMgr.start()
end

function RobotBase:_on_stop()
end

function RobotBase:_on_release()
    self._timer_proxy:release_all()
    CoroutineExMgr.stop()
end

function RobotBase:_on_frame()
    CoroutineExMgr.on_frame()
end

function RobotBase:_on_notify_quit()
    if Robot_Quit_State.none == self._quit_state then
        self._quit_state = Robot_Quit_State.quiting
        self:fire(Robot_Event.Notify_Quit_Game, self)
        self:stop()
    end
end

function RobotBase:_check_can_quit()
    local can_quit = true
    if can_quit and Robot_Quit_State.quiting == self._quit_state then
        self._quit_state = Robot_Quit_State.quited
        self:release()
    end
    return can_quit
end

function RobotBase:try_quit()
    native.try_quit_game()
end

function RobotBase:_set_as_field(field_name, obj)
    if obj then
        assert(not self[field_name])
        self[field_name] = obj
    end
end



