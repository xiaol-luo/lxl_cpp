
---@class GameLogicEntity:EventMgr
---@field server GameServerBase
---@field logics LogicServiceBase
GameLogicEntity = GameLogicEntity or class("GameLogicEntity", LogicEntityBase)

function GameLogicEntity:ctor(logics, logic_name)
    GameLogicEntity.super.ctor(self, logics, logic_name)
    self._rpc_svc_proxy = self.server.rpc:create_svc_proxy()
    ---@type table<number, Fn_GameForwardHandleClientMsgFn>
    self._pid_to_client_msg_handle_fns = {}
    self._method_name_to_remote_call_handle_fns = {}
end

function GameLogicEntity:_on_init(...)
    GameLogicEntity.super._on_init(self, ...)
    self:map_client_msg_handle_fns()
    self:map_remote_call_handle_fns()
end

function GameLogicEntity:_on_start()
    GameLogicEntity.super._on_start(self)
    self:_setup_client_msg_handle_fns(true)
    self:_setup_remote_call_handle_fns(true)
end

function GameLogicEntity:_on_stop()
    GameLogicEntity.super._on_stop(self)
    self:_setup_client_msg_handle_fns(false)
    self:_setup_remote_call_handle_fns(false)
end

function GameLogicEntity:_on_release()
    GameLogicEntity.super._on_release(self)
    self._timer_proxy:release_all()
    self._rpc_svc_proxy:clear_remote_call()
    self._event_binder:release_all()
end

function GameLogicEntity:map_client_msg_handle_fns()
    self:_on_map_client_msg_handle_fns()
end

function GameLogicEntity:_on_map_client_msg_handle_fns()

end

function GameLogicEntity:map_remote_call_handle_fns()
    self:_on_map_remote_call_handle_fns()
end

function GameLogicEntity:_on_map_remote_call_handle_fns()

end

function GameLogicEntity:_setup_client_msg_handle_fns(is_setup)
    for pid, _ in pairs(self._pid_to_client_msg_handle_fns) do
        self.logics.forward_msg:set_client_msg_handle_fn(pid, nil)
    end
    if is_setup then
        for pid, handle_fn in pairs(self._pid_to_client_msg_handle_fns) do
            self.logics.forward_msg:set_client_msg_handle_fn(pid, Functional.make_closure(handle_fn, self))
        end
    end
end

function GameLogicEntity:_setup_remote_call_handle_fns(is_setup)
    for method_name, _ in pairs(self._method_name_to_remote_call_handle_fns) do
        self._rpc_svc_proxy:set_remote_call_handle_fn(method_name, nil)
    end
    if is_setup then
        for method_name, handle_fn in pairs(self._method_name_to_remote_call_handle_fns) do
            self._rpc_svc_proxy:set_remote_call_handle_fn(method_name, Functional.make_closure(handle_fn, self))
        end
    end
end

