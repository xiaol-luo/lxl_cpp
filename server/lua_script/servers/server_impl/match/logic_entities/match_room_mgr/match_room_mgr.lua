
---@class MatchRoomMgr:GameLogicEntity
MatchRoomMgr = MatchRoomMgr or class("MatchRoomMgr", GameLogicEntity)

function MatchRoomMgr:ctor(logics, logic_name)
    MatchMgr.super.ctor(self, logics, logic_name)
    ---@type MatchServiceMgr
    self.server = self.server

    ---@type table<string, MatchGameBase>
    self._key_to_match_game  = {}
    self._match_mgr = nil
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

    do
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
    self._key_to_match_game[match_game.unique_key] = match_game
    -- log_print("MatchRoomMgr:handle_match_game", table.size(self._key_to_match_game), match_game)
end

--- rpc函数

function MatchRoomMgr:_on_map_remote_call_handle_fns()
    -- self._method_name_to_remote_call_handle_fns[Rpc.match.method.join_match] = Functional.make_closure(self._on_rpc_join_match, self)
end

---@param rpc_rsp RpcRsp
function MatchRoomMgr:_on_rpc_join_match(rpc_rsp, msg)
    log_print("MatchRoomMgr:_handle_remote_call_join_match", msg)
    rpc_rsp:response(Error_None)
end




