
---@class ExampleLogicMgr:EventMgr

ExampleLogicMgrBase = ExampleLogicMgrBase or class("ExampleLogicMgrBase", EventMgr)

function ExampleLogicMgrBase:ctor(_app)
    ExampleLogicMgrBase.super.ctor(self)
    self.app = _app
    ---@type table <number, ExampleLogicBase>
    self._logic_list = {}
end

function ExampleLogicMgrBase:init()
    for _, v in pairs(self._logic_list) do
        v:init()
    end
    self:_on_init()
end

function ExampleLogicMgrBase:start()
    for _, v in pairs(self._logic_list) do
        v:start()
    end
    self:_on_start()
end

function ExampleLogicMgrBase:stop()
    for _, v in pairs(self._logic_list) do
        v:stop()
    end
    self:_on_stop()
end

function ExampleLogicMgrBase:release()
    for _, v in pairs(self._logic_list) do
        v:release()
    end
    self:cancel_all()
    self:_on_release()
end

function ExampleLogicMgrBase:_add_logic_base_help(cls)
    local logic = cls:new(self)
    local logic_name = logic:get_name()
    assert(not self[logic_name])
    assert(not self._logic_list[logic_name])
    self[logic_name] = logic
    self._logic_list[logic_name] = logic
end


function ExampleLogicMgrBase:_on_init()
    -- override by subclass
end

function ExampleLogicMgrBase:_on_start()
    -- override by subclass
end

function ExampleLogicMgrBase:_on_stop()
    -- override by subclass
end

function ExampleLogicMgrBase:_on_release()
    -- override by subclass
end





