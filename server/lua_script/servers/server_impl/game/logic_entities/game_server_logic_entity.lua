
---@class GameServerLogicEntity:GameLogicEntity
GameServerLogicEntity = GameServerLogicEntity or class("GameServerLogicEntity", GameLogicEntity)

function GameServerLogicEntity:ctor(logics, logic_name)
    GameServerLogicEntity.super.ctor(self, logics, logic_name)
    ---@type table<number, Fn_GameForwardHandleClientMsgFn>
    self._pid_to_client_msg_handle_fns = {}
end

function GameServerLogicEntity:_on_init(...)
    GameServerLogicEntity.super._on_init(self, ...)
    self:map_client_msg_handle_fns()
end

function GameServerLogicEntity:_on_start()
    GameServerLogicEntity.super._on_start(self)
    self:_setup_client_msg_handle_fns(true)
end

function GameServerLogicEntity:_on_stop()
    GameServerLogicEntity.super._on_stop(self)
    self:_setup_client_msg_handle_fns(false)
end

function GameServerLogicEntity:_on_release()
    GameServerLogicEntity.super._on_release(self)
end

function GameServerLogicEntity:map_client_msg_handle_fns()
    self:_on_map_client_msg_handle_fns()
end


function GameServerLogicEntity:_setup_client_msg_handle_fns(is_setup)
    for pid, _ in pairs(self._pid_to_client_msg_handle_fns) do
        self.logics.forward_msg:set_client_msg_handle_fn(pid, nil)
    end
    if is_setup then
        for pid, handle_fn in pairs(self._pid_to_client_msg_handle_fns) do
            self.logics.forward_msg:set_client_msg_handle_fn(pid, Functional.make_closure(handle_fn, self))
        end
    end
end

function GameServerLogicEntity:_on_map_client_msg_handle_fns()
    -- override by subclass
    -- 客户端函数映射
end


