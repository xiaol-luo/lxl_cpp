
---@class LogicMgr:EventMgr
---@field fight FightLogic

LogicMgr = LogicMgr or class("LogicMgr", EventMgr)

function LogicMgr:ctor(_app)
    LogicMgr.super.ctor(self)
    self._app = _app
    self._logic_list = {}

    self:_add_logic_base_help(FightLogic)
end

function LogicMgr:init()
    for _, v in pairs(self._logic_list) do
        v:init()
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

function LogicMgr:release()
    for _, v in pairs(self._logic_list) do
        v:release()
    end
    self:cancel_all()
end



