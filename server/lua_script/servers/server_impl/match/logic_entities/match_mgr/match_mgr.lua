
---@class MatchMgr:GameLogicEntity
MatchMgr = MatchMgr or class("MatchMgr", GameLogicEntity)

function MatchMgr:ctor(logics, logic_name)
    MatchMgr.super.ctor(self, logics, logic_name)
    ---@type MatchServiceMgr
    self.server = self.server
    ---@type table<Match_Theme, MatchTeamBase>
    self._key_to_team = {}
    ---@type table<string, MatchLogicBase>
    self._theme_to_logic = {}
end

function MatchMgr:_on_init()
    MatchMgr.super._on_init(self)

    do
        local match_logic = MatchLogicSimpleFill:ctor(self, {
            match_theme = Match_Theme.two_dice,
            game_role_max_num = 2,
        })
        self._theme_to_logic[Match_Theme.two_dice] = match_logic
    end


end

function MatchMgr:_on_start()
    MatchMgr.super._on_start(self)
end

function MatchMgr:_on_stop()
    MatchMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function MatchMgr:_on_release()
    MatchMgr.super._on_release(self)
end

function MatchMgr:_on_update()
    -- log_print("MatchMgr:_on_update")
    MatchMgr.super._on_update(self)
end

function MatchMgr:_create_match_team(match_theme, ask_role_id, teammate_role_ids, extra_param)
    local logic = self:get_match_logic(match_theme)
    if not logic then
        return nil
    end

    local ret = logic:create_match_team(ask_role_id, teammate_role_ids, extra_param)
    return ret
end

function MatchMgr:get_match_team(match_key)
    local ret = self._key_to_team[match_key]
    return ret
end

function MatchMgr:get_match_logic(match_theme)
    local ret = self._theme_to_logic[match_theme]
    return ret
end

--- rpc函数


function MatchMgr:_on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.match.method.join_match] = Functional.make_closure(self._on_rpc_join_match, self)
    self._method_name_to_remote_call_handle_fns[Rpc.match.method.quit_match] = Functional.make_closure(self._on_rpc_quit_match, self)
end

---@param rpc_rsp RpcRsp
function MatchMgr:_on_rpc_join_match(rpc_rsp, msg)
    log_print("MatchMgr:_handle_remote_call_join_match", msg)
    rpc_rsp:response(Error_None)
end

---@param rpc_rsp RpcRsp
function MatchMgr:_on_rpc_quit_match(rpc_rsp, msg)
    log_print("MatchMgr:_on_rpc_quit_match", msg)
    rpc_rsp:response(Error_None)
end



