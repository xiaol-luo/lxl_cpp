
---@class LogicEntity:EventMgr
---@field server GameServerBase
---@field logics LogicServiceBase
LogicEntity = LogicEntity or class("LogicEntity", EventMgr)

function LogicEntity:ctor(logics, logic_name)
    LogicEntity.super.ctor(self)
    self.logics = logics
    self._logic_name = logic_name
    self.server = self.logics.server
    self._curr_state = Logic_Entity_State.Free
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
    ---@type EventBinder
    self._event_binder = EventBinder:new()
    ---@type RpcServiceProxy
    self._rpc_svc_proxy = self.server.rpc:create_svc_proxy()

    self._pid_to_client_msg_handle_fns = {}
    self._method_name_to_remote_call_handle_fns = {}
end

function LogicEntity:set_error(error_num, error_msg)
    self.logics._error_num = error_num
    self.logics._error_msg = error_msg
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
    self:map_client_msg_handle_fns()
    self:map_remote_call_handle_fns()
end

function LogicEntity:start()
    self._curr_state = Logic_Entity_State.Started
    self:_setup_client_msg_handle_fns(true)
    self:_setup_remote_call_handle_fns(true)
    self:_on_start()
end

function LogicEntity:stop()
    self._curr_state = Logic_Entity_State.Stopped
    self:_setup_client_msg_handle_fns(false)
    self:_setup_remote_call_handle_fns(false)
    self:_on_stop()
end

function LogicEntity:release()
    self._curr_state = Logic_Entity_State.Released
    self._timer_proxy:release_all()
    self._rpc_svc_proxy:clear_remote_call()
    self._event_binder:release_all()
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

function LogicEntity:map_client_msg_handle_fns()
    self:_on_map_client_msg_handle_fns()
end

function LogicEntity:_on_map_client_msg_handle_fns()

end

function LogicEntity:map_remote_call_handle_fns()
    self:_on_map_remote_call_handle_fns()
end

function LogicEntity:_on_map_remote_call_handle_fns()

end

function LogicEntity:_setup_client_msg_handle_fns(is_setup)
    for pid, _ in pairs(self._pid_to_client_msg_handle_fns) do
        self.logics.forward_msg:set_client_msg_handle_fn(pid, nil)
    end
    if is_setup then
        for pid, handle_fn in pairs(self._pid_to_client_msg_handle_fns) do
            self.logics.forward_msg:set_client_msg_handle_fn(pid, Functional.make_closure(handle_fn, self))
        end
    end
end

function LogicEntity:_setup_remote_call_handle_fns(is_setup)
    for method_name, _ in pairs(self._method_name_to_remote_call_handle_fns) do
        self._rpc_svc_proxy:set_remote_call_handle_fn(method_name, nil)
    end
    if is_setup then
        for method_name, handle_fn in pairs(self._method_name_to_remote_call_handle_fns) do
            self._rpc_svc_proxy:set_remote_call_handle_fn(method_name, Functional.make_closure(handle_fn, self))
        end
    end
end

