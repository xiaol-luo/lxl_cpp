
---@class LogicMgr:LuaAppLogicBase
---@field fight FightLogic

LogicMgr = LogicMgr or class("LogicMgr", LuaAppLogicBase)

function LogicMgr:ctor(_app, logic_name)
    LogicMgr.super.ctor(self, _app, logic_name)
    self._logic_list = {}

    self:_add_logic_base_help(FightLogic)
end

function LogicMgr:_on_init()
    LogicMgr.super._on_init(self)
    for _, v in pairs(self._logic_list) do
        v:init()
    end
end

function LogicMgr:_on_start()
    LogicMgr.super._on_init(self)
    for _, v in pairs(self._logic_list) do
        v:start()
    end
end

function LogicMgr:_on_stop()
    LogicMgr.super._on_init(self)
    for _, v in pairs(self._logic_list) do
        v:stop()
    end
end

function LogicMgr:_on_release()
    LogicMgr.super._on_release(self)
    for _, v in pairs(self._logic_list) do
        v:release()
    end
end

function LogicMgr:_add_logic_base_help(cls)
    local logic = cls:new(self)
    local logic_name = logic:get_name()
    assert(not self[logic_name])
    assert(not self._logic_list[logic_name])
    self[logic_name] = logic
    self._logic_list[logic_name] = logic
end




