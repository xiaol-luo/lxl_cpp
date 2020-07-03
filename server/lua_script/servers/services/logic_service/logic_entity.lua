
---@class LogicEntity
---@field server ServerBase
---@field logic_svc LogicServiceBase
LogicEntity = LogicEntity or class("LogicEntity", EventMgr)

function LogicEntity:ctor(logic_svc, logic_name)
    LogicEntity.super.ctor(self)
    self.logic_svc = logic_svc
    self._logic_name = logic_name
    self.server = self.logic_svc.server
    self._curr_state = Logic_Entity_State.Free
    self._timer_proxy = TimerProxy:new()
    ---@type TimerProxy
    self._event_binder = EventBinder:new()
    ---@type RpcServiceProxy
    self._rpc_svc_proxy = self.server.rpc:create_svc_proxy()
end

function LogicEntity:set_error(error_num, error_msg)
    self.logic_svc._error_num = error_num
    self.logic_svc._error_msg = error_msg
end

function LogicEntity:get_name()
    return self._logic_name
end

function LogicEntity:get_curr_state()
    return self._curr_state
end

function LogicEntity:init(...)
    self._curr_state = Logic_Entity_State.Inited
    self:_on_init(...)
end

function LogicEntity:start()
    self._curr_state = Logic_Entity_State.Started
    self:_on_start()
end

function LogicEntity:stop()
    self._curr_state = Logic_Entity_State.Stopped
    self:_on_stop()
end

function LogicEntity:release()
    self._curr_state = Logic_Entity_State.Released
    self._timer_proxy:release_all()
    self:_on_release()
end

function LogicEntity:update()
    self:_on_update()
end

function LogicEntity:_on_init(...)

end

function LogicEntity:_on_start()

end

function LogicEntity:_on_stop()

end

function LogicEntity:_on_release()

end

function LogicEntity:_on_update()

end

