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
    self._role_id_to_match = {}
end


function GameMatchMgr:_on_init()
    GameMatchMgr.super._on_init(self)
    self._role_mgr = self.logics.role_mgr
    self._room_mgr = self.logics.room_mgr
    self._forward_msg = self.logics.forward_msg

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
    self._method_name_to_remote_call_handle_fns[Rpc.game.method.test_match] = Functional.make_closure(self._on_rpc_test_match, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.method.ask_role_accept_match] = Functional.make_closure(self._on_rpc_ask_role_accept_match, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.method.notify_matching] = Functional.make_closure(self._on_rpc_notify_matching, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.method.notify_match_succ] = Functional.make_closure(self._on_rpc_notify_match_succ, self)
    self._method_name_to_remote_call_handle_fns[Rpc.game.method.notify_match_over] = Functional.make_closure(self._on_rpc_match_over, self)
end

---@param rpc_rsp RpcRsp
function GameMatchMgr:_on_rpc_test_match(rpc_rsp, ...)
    log_print("GameMatchMgr:_on_rpc_test_match ", ...)
    rpc_rsp:response(Error_None, ...)
end

---@param rpc_rsp RpcRsp
function GameMatchMgr:_on_rpc_ask_role_accept_match(rpc_rsp, role_id, msg)
    log_print("GameMatchMgr:_on_rpc_ask_role_accept_match")
    local error_num = Error_None
    local is_accept = true
    repeat
        local game_role = self.logics.role_mgr:get_role(role_id)
        if not game_role then
            is_accept = false
            break
        end
        local match = self:get_match(role_id)
        if not match then
            if not game_role then
                is_accept = false
                break
            end
            match = GameMatchItem:new()
            match.role_id = role_id
            match.match_server_key = rpc_rsp.from_host
            match.match_key = msg.match_key
            match.match_theme = msg.match_theme
            match.leader_role_id = msg.role_id
            match.teammate_role_ids = msg.teammate_role_ids
            self._role_id_to_match[role_id] = match
        else
            if match.match_key ~= msg.match_key then
                is_accept = false
                break
            end
            if Game_Match_Item_State.accepted_join == match.state then
                break
            end
            if Game_Match_Item_State.wait_join_confirm ~= match.state then
                is_accept = false
                break
            end
        end

        -- todo: 如果必要，可以在这里插入询问客户端是否加入匹配的逻辑
        -- 暂时处理为：只要数据合法，就必然接受
        match.state = Game_Match_Item_State.accepted_join
    until true

    rpc_rsp:response(Error_None, is_accept)
    self:sync_state(role_id)
end

function GameMatchMgr:_on_rpc_notify_matching(rpc_rsp, role_id, match_key)
    log_print("GameMatchMgr:_on_rpc_notify_matching")
    rpc_rsp:response(Error_None)

    local match = self:get_match(role_id)
    if match and match.match_key == match_key then
        match.state = Game_Match_Item_State.matching
        self:sync_state(role_id)
    end
end

function GameMatchMgr:_on_rpc_notify_match_succ(rpc_rsp, role_id, match_key)
    log_print("GameMatchMgr:_on_rpc_notify_match_succ")
    rpc_rsp:response(Error_None)

    local match = self:get_match(role_id)
    if match and match.match_key == match_key then
        match.state = Game_Match_Item_State.match_succ
        self:sync_state(role_id)
    end
end

function GameMatchMgr:_on_rpc_match_over(rpc_rsp, role_id, match_key)
    log_print("GameMatchMgr:_on_rpc_match_over")
    rpc_rsp:response(Error_None)
    if self:remove_match(role_id, match_key) then
        self:sync_state(role_id)
    end
end

---@param msg PB_ReqJoinMatch
function GameMatchMgr:_on_msg_join_match(from_gate, gate_netid, role_id, pid, msg)
    ---@type Error.join_match
    local error_num = Error_None
    repeat
        local game_role = self._role_mgr:get_role_in_game(role_id)
        if not game_role then
            error_num = Error.join_match.role_not_in_game_server
            break
        end
        local match = self:get_match(role_id)
        if match and Game_Match_Item_State.idle ~= match.state then
            error_num = Error.join_match.already_matching
            break
        end
        local match_server_key = self.server.peer_net:random_server_key(Server_Role.Match)
        if not match_server_key then
            error_num = Error.join_match.no_available_match_server
            break
        end
        if not match then
            match = GameMatchItem:new()
            self._role_id_to_match[role_id] = match
        end
        match.match_server_key = match_server_key
        match.match_theme = msg.match_theme
        match.role_id = role_id
        match.match_key = gen_uuid()
        match.leader_role_id = role_id
        match.teammate_role_ids = {} -- from msg
        table.insert(match.teammate_role_ids, role_id)
        if match.teammate_role_ids then
            table.append(match.teammate_role_ids, msg.teammate_role_ids)
        end
        local game_role = self.logics.role_mgr:get_role(role_id)
        if game_role then
            game_role.match:set_match_data(false,match.match_server_key, match.match_theme, match.match_theme)
        end
        match.state = Game_Match_Item_State.wait_join_confirm
        self._rpc_svc_proxy:call(
                Functional.make_closure(self._on_cb_join_match, self, from_gate, gate_netid, role_id, match.match_key),
                match.match_server_key, Rpc.match.method.join_match, {
                    match_theme = match.match_theme,
                    match_key = match.match_key,
                    role_id = match.role_id,
                    teammate_role_ids = match.teammate_role_ids,
                    extra_param = {}
                })
    until true
    log_print("GameMatchMgr:_on_msg_join_match ", error_num, from_gate, gate_netid, role_id)
end

function GameMatchMgr:_on_cb_join_match(from_gate, gate_netid, role_id, match_key, rpc_error_num, error_num)
    log_print("GameMatchMgr:_on_cb_join_match ", role_id, match_key, rpc_error_num, error_num)
    local picked_error_num = pick_error_num(rpc_error_num, error_num)
    if Error_None ~= error_num then
        self:remove_match(role_id, match_key)
    end
    self._forward_msg:send_msg_to_client(from_gate, gate_netid, Fight_Pid.rsp_join_match,{
                error_num = picked_error_num,
                match_key = match_key,
            })
    self:sync_state(role_id, from_gate, gate_netid)
end

---@param msg PB_ReqQuitMatch
function GameMatchMgr:_on_msg_quit_match(from_gate, gate_netid, role_id, pid, msg)
    ---@type Error.quit_match
    local error_num = Error_None
    repeat
        local match = self:get_match(role_id)
        if not match then
            break
        end
        if not msg.ignore_match_key and match.match_key ~= msg.match_key then
            error_num = Error.quit_match.match_key_not_same
            break
        end
        if Game_Match_Item_State.match_succ == match.state then
            error_num = Error_None.quit_match.can_not_quit_when_match_succ
            break
        end
        self._rpc_svc_proxy:call(nil, match.match_server_key, Rpc.match.method.quit_match, {
            role_id = match.role_id,
            Match_Theme = match.match_theme,
            match_key = match.match_key,
        })
        self:remove_match(role_id)
    until true
    self._forward_msg:send_msg_to_client(from_gate, gate_netid, Fight_Pid.rsp_quit_match, { error_num = error_num })
    self:sync_state(role_id, from_gate, gate_netid)
    log_print("GameMatchMgr:_on_msg_quit_match ", role_id, error_num)
end

function GameMatchMgr:_on_msg_req_match_state(from_gate, gate_netid, role_id, pid, msg)
    log_debug("GameMatchMgr:_on_msg_req_match_state %s", role_id)
    self:sync_state(role_id, from_gate, gate_netid)
end

function GameMatchMgr:sync_state(role_id, from_gate, gate_netid)
    local msg = {
        state = Game_Match_Item_State.idle
    }
    local match = self:get_match(role_id)
    if not match then

    end
    if from_gate and gate_netid then
        self._forward_msg:send_msg_to_client(from_gate, gate_netid, Fight_Pid.sync_match_state, msg)
    else
        local game_role = self.logics.role_mgr:get_role(role_id)
        if game_role then
            game_role:send_to_client(Fight_Pid.sync_match_state, msg)
        end
    end
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
    log_debug("GameMatchMgr:_on_event_role_leave_game %s", game_role:get_role_id())
end

function GameMatchMgr:get_match(role_id)
    local ret = self._role_id_to_match[role_id]
    return ret
end

function GameMatchMgr:remove_match(role_id, match_key)
    local is_removed = false
    local match = self._role_id_to_match[role_id]
    if match then
        if nil == match_key or match_key == match.match_key then
            is_removed = true
            match.state = Game_Match_Item_State.match_over
            self._role_id_to_match[role_id] = nil
            local game_role = self.logics.role_mgr:get_role(role_id)
            if game_role then
                game_role.match:set_match_data(false,nil, nil, nil)
            end
        end
    end
    return is_removed
end

--- rpc函数


