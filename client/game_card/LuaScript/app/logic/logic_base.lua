
---@class LogicBase:EventMgr
LogicBase = LogicBase or class("LogicBase", EventMgr)

function LogicBase:ctor(logic_mgr, name)
    LogicBase.super.ctor(self)
    self._name = name
    ---@type LogicMgr
    self._logic_mgr = logic_mgr
    ---@type LuaApp
    self._app = self._logic_mgr._app
    ---@type EventBinder
    self._event_binder = EventBinder:new()
end

function LogicBase:get_name()
    return self._name
end

function LogicBase:init()
    self:_on_init()
end

function LogicBase:start()
    self:_on_start()
end

function LogicBase:stop()
    self:_on_stop()
end

function LogicBase:release()
    self:cancel_all()
    self._event_binder:release_all()
    self:_on_release()
end

function LogicBase:_on_init()

end

function LogicBase:_on_start()

end

function LogicBase:_on_stop()

end

function LogicBase:_on_release()

end

