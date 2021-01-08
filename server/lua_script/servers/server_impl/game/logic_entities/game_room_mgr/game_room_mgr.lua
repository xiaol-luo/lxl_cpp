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
    self._pid_to_client_msg_handle_fns[Fight_Pid.pull_room_state] = Functional.make_closure(self._on_msg_pull_room_state, self)
    self._pid_to_client_msg_handle_fns[Fight_Pid.rpl_svr_accept_enter_room] = Functional.make_closure(self._on_msg_rpl_svr_accept_enter_room, self)
end

--- rpc函数
function GameRoomMgr:_on_map_remote_call_handle_fns()
    GameRoomMgr.super._on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.game.ask_accept_enter_room] = Functional.make_closure(self._on_rpc_ask_accept_enter_room, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.notify_enter_room] = Functional.make_closure(self._on_rpc_notify_enter_room, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.notify_room_over] = Functional.make_closure(self._on_rpc_notify_room_over, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.sync_room_state] = Functional.make_closure(self._on_rpc_sync_room_state, self)
end

function GameRoomMgr:rpl_accept_enter_room(role_id, match_server_key, room_key, is_accept)
    if not is_accept then
        self._rpc_svc_proxy:call(nil, match_server_key, Rpc.match.rpl_ask_accept_enter_room, room_key, role_id, false)
    else
        self._rpc_svc_proxy:call(
                Functional.make_closure(self._on_cb_rpl_accept_enter_room, self, role_id, room_key),
                match_server_key, Rpc.match.rpl_ask_accept_enter_room, room_key, role_id, true)
    end
end

function GameRoomMgr:_on_cb_rpl_accept_enter_room(role_id, room_key, rpc_error_num, error_num)
    local picked_error_num = pick_error_num(rpc_error_num, error_num)
    if Error_None == picked_error_num then
        local room = GameRoom:new()
        room.role_id = role_id
        room.room_key = room_key
        room.state = Game_Room_Item_State.accept_enter
        self._role_id_to_room[role_id] = room
        self:sync_state(role_id)
        -- log_print("GameRoomMgr:_on_cb_rpl_accept_enter_room", role_id, room_key, rpc_error_num, error_num, room)
    end
end

---@param rpc_rsp RpcRsp
function GameRoomMgr:_on_rpc_ask_accept_enter_room(rpc_rsp, role_id, room_key)
    rpc_rsp:response(Error_None)
    local game_role = self.logics.role_mgr:get_role(role_id)
    if game_role then
        game_role:send_msg(Fight_Pid.ask_cli_accept_enter_room, {
            room_key = room_key,
            match_server_key = rpc_rsp.from_host,
        })
    else
        self:rpl_accept_enter_room(role_id, rpc_rsp.from_host, room_key, false)
    end
end

---@param rpc_rsp RpcRsp
function GameRoomMgr:_on_rpc_notify_enter_room(rpc_rsp, role_id, room_key)
    local is_accept = true
    local room = self:get_room(role_id)
    if not room then
        is_accept = true
    end
    if room and room.room_key and room.room_key ~= room_key then
        is_accept = false
    end
    -- log_print("GameRoomMgr:_on_rpc_notify_enter_room", role_id, room_key, is_accept, room)
    rpc_rsp:response(Error_None, is_accept)
    if is_accept then
        room.room_server_key = rpc_rsp.from_host
        room.room_key = room_key
        room.state = Game_Room_Item_State.in_room
        room.remote_room.state = Room_State.setup
        self:sync_state(role_id)
    end
end

---@param rpc_rsp RpcRsp
function GameRoomMgr:_on_rpc_notify_room_over(rpc_rsp, role_id, room_key)
    log_print("GameRoomMgr:_on_rpc_notify_room_over", role_id, room_key)
    rpc_rsp:response(Error_None)
    local room  = self:get_room(role_id, room_key)
    if room then
        room.state = Game_Room_Item_State.all_over
        room.remote_room.state = Room_State.all_over
        self:sync_state(role_id)
        self:remove_room(role_id, room_key)
    end
end

---@param rpc_rsp RpcRsp
function GameRoomMgr:_on_rpc_sync_room_state(rpc_rsp, role_id, room_key, room_state)
    log_print("GameRoomMgr:_on_rpc_sync_room_state", role_id, room_key, room_state.state)
    rpc_rsp:response(Error_None)
    local room = self:get_room(role_id, room_key)
    if not room then
        return
    end
    room.remote_room.state = room_state.state
    room.remote_room.match_theme = room_state.match_theme
    room.remote_room.fight_key = room_state.fight_key
    room.remote_room.fight_server_key = room_state.fight_server_key
    room.remote_room.fight = room_state.fight
    room.remote_room.raw_msg = room_state.room_state
    self:sync_state(role_id)
end

---@return GameRoom
function GameRoomMgr:get_room(role_id, room_key)
    local room = self._role_id_to_room[role_id]
    if room and room_key then
        if room_key ~= room.room_key then
            room = nil
        end
    end
    return room
end

function GameRoomMgr:remove_room(role_id, room_key)
    local room = self:get_room(role_id, room_key)
    if room then
        self._role_id_to_room[role_id] = nil
    end
    return room
end

function GameRoomMgr:_on_msg_pull_room_state(from_gate, gate_netid, role_id, pid, msg)
    self:sync_state(role_id, from_gate, gate_netid)
end

function GameRoomMgr:sync_state(role_id, from_gate, gate_netid)
    local msg = {
        state = Game_Room_Item_State.idle
    }
    local room = self:get_room(role_id)
    if room then
        msg.state = room.state
        msg.room_key = room.room_key
        msg.remote_room_state = room.remote_room.state
        msg.match_theme = room.remote_room.match_theme
        msg.fight_key = room.remote_room.fight_key
        if room.remote_room.fight then
            msg.fight_server_ip = room.remote_room.fight.ip
            msg.fight_server_port = room.remote_room.fight.port
            msg.fight_token = room.remote_room.fight.token
        end
    end
    if from_gate and gate_netid then
        self._forward_msg:send_msg_to_client(from_gate, gate_netid, Fight_Pid.sync_room_state, msg)
    else
        local game_role = self.logics.role_mgr:get_role(role_id)
        if game_role then
            game_role:send_msg(Fight_Pid.sync_room_state, msg)
        end
    end
end

function GameRoomMgr:_on_msg_rpl_svr_accept_enter_room(from_gate, gate_netid, role_id, pid, msg)
    self:rpl_accept_enter_room(role_id, msg.match_server_key, msg.room_key, msg.is_accept)
end
