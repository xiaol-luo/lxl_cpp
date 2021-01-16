
---@class ExampleLogicBase:EventMgr
ExampleLogicBase = ExampleLogicBase or class("ExampleLogicBase", EventMgr)

function ExampleLogicBase:ctor(logic_mgr, name)
    ExampleLogicBase.super.ctor(self)
    self._name = name
    ---@type LogicMgr
    self._logic_mgr = logic_mgr
    ---@type LuaApp
    self.app = self._logic_mgr.app
    ---@type EventBinder
    self._event_binder = EventBinder:new()
end

function ExampleLogicBase:get_name()
    return self._name
end

function ExampleLogicBase:init()
    self:_on_init()
end

function ExampleLogicBase:start()
    self:_on_start()
end

function ExampleLogicBase:stop()
    self:_on_stop()
end

function ExampleLogicBase:release()
    self:cancel_all()
    self._event_binder:release_all()
    self:_on_release()
end

function ExampleLogicBase:_on_init()
    -- override by subclass
end

function ExampleLogicBase:_on_start()
    -- override by subclass
end

function ExampleLogicBase:_on_stop()
    -- override by subclass
end

function ExampleLogicBase:_on_release()
    -- override by subclass
end

