
---@class GameLogicEntity:LogicEntityBase
---@field server GameServerBase
---@field logics LogicServiceBase
GameLogicEntity = GameLogicEntity or class("GameLogicEntity", LogicEntityBase)

function GameLogicEntity:ctor(logics, logic_name)
    GameLogicEntity.super.ctor(self, logics, logic_name)
    ---@type RpcServiceProxy
    self._rpc_svc_proxy = self.server.rpc:create_svc_proxy()
    ---@type table<number, Fn_RpcRemoteCallHandleFn>
    self._method_name_to_remote_call_handle_fns = {}
end

function GameLogicEntity:_on_init(...)
    GameLogicEntity.super._on_init(self, ...)
    self:map_remote_call_handle_fns()
end

function GameLogicEntity:_on_start()
    GameLogicEntity.super._on_start(self)
    self:_setup_remote_call_handle_fns(true)
end

function GameLogicEntity:_on_stop()
    GameLogicEntity.super._on_stop(self)
    self:_setup_remote_call_handle_fns(false)
end

function GameLogicEntity:_on_release()
    GameLogicEntity.super._on_release(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function GameLogicEntity:map_remote_call_handle_fns()
    self:_on_map_remote_call_handle_fns()
end

function GameLogicEntity:_setup_remote_call_handle_fns(is_setup)
    for method_name, _ in pairs(self._method_name_to_remote_call_handle_fns) do
        self._rpc_svc_proxy:set_remote_call_handle_fn(method_name, nil)
    end
    if is_setup then
        for method_name, handle_fn in pairs(self._method_name_to_remote_call_handle_fns) do
            self._rpc_svc_proxy:set_remote_call_handle_fn(method_name, handle_fn)
        end
    end
end

function GameLogicEntity:_on_map_remote_call_handle_fns()
    -- override by subclass
    -- 远程调用函数映射
end

