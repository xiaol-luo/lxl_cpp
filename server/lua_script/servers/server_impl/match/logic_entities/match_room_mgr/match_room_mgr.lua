
---@class MatchRoomMgr:GameLogicEntity
MatchRoomMgr = MatchRoomMgr or class("MatchRoomMgr", GameLogicEntity)

function MatchRoomMgr:ctor(logics, logic_name)
    MatchMgr.super.ctor(self, logics, logic_name)
    ---@type MatchServiceMgr
    self.server = self.server

    ---@type table<string, MatchGameBase>
    self._key_to_match_game  = {}
    self._match_mgr = nil

    self._key_to_room = {}
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

    if false then
        -- for test
        local pre_key = nil
        repeat
            local k, match_game = next(self._key_to_match_game, pre_key)
            if nil ~= pre_key then
                self._key_to_match_game[pre_key] = nil
            end
            if nil == k then
                break
            end
            pre_key = k
            local rand_val = math.random()
            if rand_val > 0.5 then
                local relate_role_ids = {}
                self._match_mgr:notify_handle_game_fail(match_game, relate_role_ids)
            else
                self._match_mgr:notify_handle_game_succ(match_game)
            end
        until false
        if nil ~= pre_key then
            self._key_to_match_game[pre_key] = nil
        end
    end
end

---@param match_game MatchGameBase
function MatchRoomMgr:handle_match_game(match_game)
    local match_room = MatchRoom:new()
    match_room.unique_key = gen_uuid()
    match_room.match_game = match_game
    self._key_to_room[match_room.unique_key] = match_room

    -- 1.向game_role确认进入room

    for _, match_camp in pairs(match_game.match_camps) do
        for match_key, match_team in pairs(match_camp.match_teams) do
            for _, v in pairs(match_team.teammate_role_ids) do
                local role_id = v
                match_room.role_replys[role_id] = Reply_State.pending
                self._rpc_svc_proxy:call_game_server(
                        Functional.make_closure(self._on_cb_ask_accept_enter_room, self, match_room.unique_key, role_id),
                        v, Rpc.game.ask_accept_enter_room, v, match_room.unique_key)
            end
        end
    end
end

function MatchRoomMgr:_on_cb_ask_accept_enter_room(room_key, role_id, rpc_error_num, error_num, is_accept)
    log_print("MatchRoomMgr:_on_cb_ask_accept_enter_room", room_key, role_id, rpc_error_num, error_num, is_accept)
    local match_room = self:get_room(room_key)
    if not match_room then
        return
    end
    if not match_room.role_replys[role_id] then
        return
    end
    local real_accept = true
    local picked_error_num = pick_error_num(rpc_error_num, error_num)
    if Error_None ~= picked_error_num then
        real_accept = false
    end
    if not is_accept then
        real_accept = false
    end
    match_room.role_replys[role_id] = real_accept and Reply_State.accept or Reply_State.reject
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
        log_print("xxx 1", match_room.role_replys, reject_role_ids)
        if next(reject_role_ids) then
            log_print("xxx 2")
            self:remove_room(room_key)
            self._match_mgr:notify_handle_game_fail(match_room.match_game, reject_role_ids)
        else
            log_print("xxx 3")
            self._match_mgr:notify_handle_game_succ(match_room.match_game)
            -- todo: 2.向room_server申请room
            -- for test
            self._timer_proxy:delay(function()
                log_print("xxx 4")
                local match_room = self:remove_room(room_key)
                if match_room then
                    log_print("xxx 5")
                    for _, match_camp in pairs(match_room.match_game.match_camps) do
                        for match_key, match_team in pairs(match_camp.match_teams) do
                            for _, v in pairs(match_team.teammate_role_ids) do
                                self._rpc_svc_proxy:call_game_server(nil,v,
                                        Rpc.game.notify_room_over, v, match_room.unique_key)
                            end
                        end
                    end
                end
            end, 2000)
        end
    end
end

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
    -- self._method_name_to_remote_call_handle_fns[Rpc.match.join_match] = Functional.make_closure(self._on_rpc_join_match, self)
end

---@param rpc_rsp RpcRsp
function MatchRoomMgr:_on_rpc_join_match(rpc_rsp, msg)
    log_print("MatchRoomMgr:_handle_remote_call_join_match", msg)
    rpc_rsp:response(Error_None)
end




