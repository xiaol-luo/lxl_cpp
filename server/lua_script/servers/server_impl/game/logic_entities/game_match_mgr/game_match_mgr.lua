---@class GameMatchMgr:GameServerLogicEntity
---@field logics GameLogicService
---@field server GameServer
GameMatchMgr = GameMatchMgr or class("GameMatchMgr", GameServerLogicEntity)

function GameMatchMgr:ctor(logics, logic_name)
    GameMatchMgr.super.ctor(self, logics, logic_name)
    ---@type GameRoleMgr
    self._role_mgr = nil
    ---@type GameRoomMgr
    self._room_mgr = nil
    ---@type table<number, GameMatchItem>
    self._role_id_match_map = {}
end


function GameMatchMgr:_on_init()
    GameMatchMgr.super._on_init(self)
    self._role_mgr = self.logics.role_mgr
    self._room_mgr = self.logics.room_mgr

    self:_batch_bind_events()
end

function GameMatchMgr:_on_start()
    GameMatchMgr.super._on_start(self)
end

function GameMatchMgr:_on_stop()
    GameMatchMgr.super._on_stop(self)
end

function GameMatchMgr:_on_release()
    GameMatchMgr.super._on_release(self)
end

function GameMatchMgr:_on_update()
    GameMatchMgr.super._on_update(self)
end

--- 绑定事件
function GameMatchMgr:_batch_bind_events()
    self._event_binder:bind(self._role_mgr, Game_Role_Event.enter_game, Functional.make_closure(self._on_event_role_enter_game, self))
    self._event_binder:bind(self._role_mgr, Game_Role_Event.pre_leave_game, Functional.make_closure(self._on_event_role_pre_leave_game, self))
    self._event_binder:bind(self._role_mgr, Game_Role_Event.leave_game, Functional.make_closure(self._on_event_role_leave_game, self))
end

--- 客户端函数
function GameMatchMgr:_on_map_client_msg_handle_fns()
    GameMatchMgr.super._on_map_client_msg_handle_fns(self)
    self._pid_to_client_msg_handle_fns[Fight_Pid.req_join_match] = Functional.make_closure(self._on_msg_join_match, self)
    self._pid_to_client_msg_handle_fns[Fight_Pid.req_quit_match] = Functional.make_closure(self._on_msg_quit_match, self)
    self._pid_to_client_msg_handle_fns[Fight_Pid.req_match_state] = Functional.make_closure(self._on_msg_req_match_state, self)
end

--- rpc函数
function GameMatchMgr:_on_map_remote_call_handle_fns()
    GameMatchMgr.super._on_map_remote_call_handle_fns()
    -- self._method_name_to_remote_call_handle_fns[]
end

function GameMatchMgr:_on_msg_join_match(from_gate, gate_netid, role_id, pid, msg)
    log_debug("GameMatchMgr:_on_msg_join_match %s", role_id)

    ---@type Error.match
    local error_num = Error_None
    repeat
        local game_role = self._role_mgr:get_role_in_game(role_id)
        if not game_role then
            error_num = Error.match.role_not_in_game_server
            break
        end
        local match = self:get_match(role_id)
        if match and Game_Match_Item_State.idle ~= match.state then
            error_num = Error.match.already_matching
            break
        end
        local match_server_key = self.server.peer_net:random_server_key(Server_Role.Match)
        if not match_server_key then
            error_num = Error.match.no_available_match_server
            break
        end
        if not match then
            match = GameMatchItem:new()
            self._role_id_match_map[role_id] = match
        end
        match.match_server_key = match_server_key
        match.role_id = role_id
        match.match_key = gen_uuid()
        match.leader_role_id = role_id
        match.teammate_role_ids = {} -- from msg
        table.insert(match.teammate_role_ids, role_id)

        self._rpc_svc_proxy:call(Functional.make_closure(self._on_cb_join_match, self, role_id, match.match_key),
            match.match_server_key, Rpc.match.method.join_match, match)
    until true
end

function GameMatchMgr:_on_cb_join_match(role_id, match_key, rpc_error_num, error_num)
    log_print("GameMatchMgr:_on_cb_join_match ", role_id, match_key, rpc_error_num, error_num)
end

function GameMatchMgr:_on_msg_quit_match(from_gate, gate_netid, role_id, pid, msg)
    log_debug("GameMatchMgr:_on_msg_quit_match %s", role_id)
end

function GameMatchMgr:_on_msg_req_match_state(from_gate, gate_netid, role_id, pid, msg)
    log_debug("GameMatchMgr:_on_msg_req_match_state %s", role_id)
end

function GameMatchMgr:sync_state(role_id)

end

--- 事件函数

---@param game_role GameRole
function GameMatchMgr:_on_event_role_enter_game(game_role)

end

---@param game_role GameRole
function GameMatchMgr:_on_event_role_pre_leave_game(game_role)

end

---@param game_role GameRole
function GameMatchMgr:_on_event_role_leave_game(game_role)
    log_debug("GameMatchMgr:_on_event_role_leave_game %s", game_role.get_role_id())
end

function GameMatchMgr:get_match(role_id)
    local ret = self._role_id_match_map[role_id]
    return ret
end

--- rpc函数


