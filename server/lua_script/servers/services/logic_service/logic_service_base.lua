
---@class LogicServiceBase:ServiceBase
LogicServiceBase = LogicServiceBase or class("LogicServiceBase", ServiceBase)

function LogicServiceBase:ctor(service_mgr, service_name)
    LogicServiceBase.super.ctor(self, service_mgr, service_name)
    self._logic_list = {}
end

function LogicServiceBase:add_logic(logic)
    table.insert(self._logic_list, logic)
    local name = logic:get_name()
    assert(not self[name])
    self[name] = logic
end

function LogicServiceBase:_on_init(...)
    LogicServiceBase.super._on_init(self, ...)
end

function LogicServiceBase:_on_start()
    LogicServiceBase.super._on_start(self)
    for _, v in ipairs(self._logic_list) do
        v:start()
    end
end

function LogicServiceBase:_on_stop()
    LogicServiceBase.super._on_stop(self)
    for _, v in ipairs(self._logic_list) do
        v:stop()
    end
end

function LogicServiceBase:_on_release()
    LogicServiceBase.super._on_release(self)
    for _, v in ipairs(self._logic_list) do
        v:release()
    end
    self._logic_list = {}
end

function LogicServiceBase:_on_update()
    LogicServiceBase.super._on_update(self)
    for _, v in ipairs(self._logic_list) do
        v:update()
    end
end

