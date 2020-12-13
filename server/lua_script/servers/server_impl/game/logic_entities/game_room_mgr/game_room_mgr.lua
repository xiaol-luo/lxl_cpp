---@class GameRoomMgr:GameServerLogicEntity
---@field logics GameLogicService
---@field server GameServer
GameRoomMgr = GameRoomMgr or class("GameRoomMgr", GameServerLogicEntity)

function GameRoomMgr:ctor(logics, logic_name)
    GameRoomMgr.super.ctor(self, logics, logic_name)
    self._role_mgr = nil
    self._room_mgr = nil
    self._forward_msg = nil
    self._role_id_to_room = {}
end

function GameRoomMgr:_on_init()
    GameRoomMgr.super._on_init(self)
end

function GameRoomMgr:_on_start()
    GameRoomMgr.super._on_start(self)

    self._role_mgr = self.logics.role_mgr
    self._room_mgr = self.logics.room_mgr
    self._forward_msg = self.logics.forward_msg
    self:_batch_bind_events()
end

function GameRoomMgr:_on_stop()
    GameRoomMgr.super._on_stop(self)
end

function GameRoomMgr:_on_release()
    GameRoomMgr.super._on_release(self)
end

function GameRoomMgr:_on_update()
    GameRoomMgr.super._on_update(self)
end

--- 绑定事件
function GameRoomMgr:_batch_bind_events()
    -- self._event_binder:bind(self._role_mgr, Game_Role_Event.enter_game, Functional.make_closure(self._on_event_role_enter_game, self))
end

--- 客户端函数
function GameRoomMgr:_on_map_client_msg_handle_fns()
    GameRoomMgr.super._on_map_client_msg_handle_fns(self)
    --  self._pid_to_client_msg_handle_fns[Fight_Pid.req_join_match] = Functional.make_closure(self._on_msg_join_match, self)
end

--- rpc函数
function GameRoomMgr:_on_map_remote_call_handle_fns()
    GameRoomMgr.super._on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.game.ask_accept_enter_room] = Functional.make_closure(self._on_rpc_ask_accept_enter_room, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.notify_room_over] = Functional.make_closure(self._on_rpc_notify_room_over, self)
end

---@param rpc_rsp RpcRsp
function GameRoomMgr:_on_rpc_ask_accept_enter_room(rpc_rsp, role_id, room_key)
    log_print("GameRoomMgr:_on_rpc_ask_accept_enter_room", role_id, room_key)
    local is_accept = math.random() > 0.5 and true or false
    rpc_rsp:response(Error_None, is_accept)
    if is_accept then
        local room = GameRoom:new()
        room.room_key = room_key
        self._role_id_to_room[role_id] = room
    end
end

---@param rpc_rsp RpcRsp
function GameRoomMgr:_on_rpc_notify_room_over(rpc_rsp, role_id, room_key)
    log_print("GameRoomMgr:_on_rpc_notify_room_over", role_id, room_key)
    rpc_rsp:response(Error_None)
    local room = self._role_id_to_room[role_id]
    if room and room.room_key == room_key then
        self._role_id_to_room[role_id] = nil
    end
end
