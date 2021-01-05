
---@class MatchRoomMgr:GameLogicEntity
MatchRoomMgr = MatchRoomMgr or class("MatchRoomMgr", GameLogicEntity)

function MatchRoomMgr:ctor(logics, logic_name)
    MatchMgr.super.ctor(self, logics, logic_name)
    ---@type MatchServiceMgr
    self.server = self.server
    self._match_mgr = nil
    ---@type table<string, MatchRoom>
    self._key_to_room = {}

    self._last_check_room_timeout = 0
    self._wait_sec_for_role_accept_enter_room = 10
    self._wait_sec_for_setup_room = 20
end

function MatchRoomMgr:_on_init()
    MatchRoomMgr.super._on_init(self)
end

function MatchRoomMgr:_on_start()
    MatchRoomMgr.super._on_start(self)
    self._match_mgr = self.server.logics.match_mgr
end

function MatchRoomMgr:_on_stop()
    MatchRoomMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function MatchRoomMgr:_on_release()
    MatchRoomMgr.super._on_release(self)
end

function MatchRoomMgr:_on_update()
    MatchRoomMgr.super._on_update(self)

    local now_sec = logic_sec()
    if now_sec > self._last_check_room_timeout + 1 then
        self._last_check_room_timeout = now_sec
        local timeout_rooms = {}
        for _, room in pairs(self._key_to_room) do
            if now_sec > room.timeout_timestamp then
                table.insert(timeout_rooms, room)
            end
        end
        if next(timeout_rooms) then
            local role_ids = {}
            for _, room in ipairs(timeout_rooms) do
                self:remove_room(room.room_key)
                self._match_mgr:notify_handle_game_fail(room.match_game, role_ids)
            end
        end
    end
end

---@param match_game MatchGameBase
function MatchRoomMgr:handle_match_game(match_game)
    local match_room = MatchRoom:new()
    match_room.room_key = gen_uuid()
    match_room.match_game = match_game
    self._key_to_room[match_room.room_key] = match_room

    -- 1.向game_role确认进入room
    match_room.timeout_timestamp = logic_sec() + self._wait_sec_for_role_accept_enter_room
    for _, match_camp in pairs(match_game.match_camps) do
        for match_key, match_team in pairs(match_camp.match_teams) do
            for _, v in pairs(match_team.teammate_role_ids) do
                local role_id = v
                match_room.role_replys[role_id] = Reply_State.pending
                self._rpc_svc_proxy:call_game_server(
                        Functional.make_closure(nil, self, match_room.room_key, role_id),
                        v, Rpc.game.ask_accept_enter_room, v, match_room.room_key)
            end
        end
    end
end

---@param cb_fn fun(room_key, rpc_error_num:number, error_num:number):void
function MatchRoomMgr:try_setup_room(room_key, left_try_times, cb_fn)
    local match_room = self:get_room(room_key)
    if not match_room then
        return
    end
    if not match_room.room_server_key then
        match_room.room_server_key = self.server.peer_net:random_server_key(Server_Role.Room)
        if not match_room.room_server_key then
            if left_try_times > 0 then
                self._timer_proxy:delay(Functional.make_closure(
                        self.try_setup_room, self, room_key, left_try_times - 1, cb_fn), 1 * 1000)
            else
                if cb_fn then
                    cb(room_key, Error_Not_Available_Server, Error_None)
                end
            end
            return
        end
    end
    self._rpc_svc_proxy:call(function(rpc_error_num, error_num)
        log_print("try_setup_room call back ", rpc_error_num, error_num)
        local picked_error_num = pick_error_num(rpc_error_num, error_num)
        if Error_None == picked_error_num or left_try_times <= 0 then
            if cb_fn then
                cb_fn(room_key, rpc_error_num, error_num)
            end
        else
            if left_try_times > 0 then
                self._timer_proxy:delay(Functional.make_closure(
                        self.try_setup_room, self, room_key, left_try_times - 1, cb_fn), 1 * 1000)
            end
        end
    end, match_room.room_server_key, Rpc.room.setup_room, room_key, match_room.match_game:collect_setup_room_data())
end

function MatchRoomMgr:_on_cb_setup_room(room_key, rpc_error_num, error_num)
    log_print("MatchRoomMgr:_on_cb_setup_room ", room_key, rpc_error_num, error_num)
    local match_room = self:get_room(room_key)
    if not match_room then
        return
    end
    local picked_error_num = pick_error_num(rpc_error_num, error_num)
    if Error_None ~= picked_error_num then
        self._match_mgr:notify_handle_game_fail(match_room.match_game, {})
    else
        self._match_mgr:notify_handle_game_succ(match_room.match_game)
    end
    self:remove_room(room_key)
end

---@return MatchRoom
function MatchRoomMgr:get_room(room_key)
    local ret = self._key_to_room[room_key]
    return ret
end

function MatchRoomMgr:remove_room(room_key)
    local ret = self._key_to_room[room_key]
    self._key_to_room[room_key] = nil
    return ret
end

--- rpc函数

function MatchRoomMgr:_on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.match.rpl_ask_accept_enter_room] = Functional.make_closure(self._on_rpc_rpl_ask_accept_enter_room, self)
end

---@param rpc_rsp RpcRsp
function MatchRoomMgr:_on_rpc_rpl_ask_accept_enter_room(rpc_rsp, room_key, role_id, is_accept)
    log_print("MatchRoomMgr:_on_rpc_rpl_ask_accept_enter_room", room_key, role_id, is_accept)
    local error_num = Error_None
    local match_room = nil
    repeat
        match_room = self:get_room(room_key)
        if not match_room then
            error_num = Error.ask_accept_enter_room.not_find_room
            break
        end
        if not match_room.role_replys[role_id] then
            error_num = Error.ask_accept_enter_room.role_not_in_room
            break
        end
        match_room.role_replys[role_id] = is_accept and Reply_State.accept or Reply_State.reject
    until true
    rpc_rsp:response(error_num)

    if Error_None == error_num then
        local no_paneding = true
        local reject_role_ids = {}
        for role_id, reply_state in pairs(match_room.role_replys) do
            if Reply_State.pending == reply_state then
                no_paneding = false
            end
            if Reply_State.reject == reply_state then
                table.insert(reject_role_ids, role_id)
            end
        end
        if no_paneding then
            if next(reject_role_ids) then
                self:remove_room(room_key)
                self._match_mgr:notify_handle_game_fail(match_room.match_game, reject_role_ids)
                for role_id, _ in pairs(match_room.role_replys) do
                    self._rpc_svc_proxy:call_game_server(nil,  role_id, Rpc.game.notify_room_over, match_room.room_key)
                end
            else
                match_room.timeout_timestamp = logic_sec() + self._wait_sec_for_setup_room
                self:try_setup_room(match_room.room_key, 1, Functional.make_closure(self._on_cb_setup_room, self))
            end
        end
    end
end




