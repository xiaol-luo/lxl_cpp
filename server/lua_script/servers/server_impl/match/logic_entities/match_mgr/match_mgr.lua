
---@class MatchMgr:GameLogicEntity
MatchMgr = MatchMgr or class("MatchMgr", GameLogicEntity)

function MatchMgr:ctor(logics, logic_name)
    MatchMgr.super.ctor(self, logics, logic_name)
    ---@type MatchServiceMgr
    self.server = self.server
    ---@type table<Match_Theme, MatchTeamBase>
    self._key_to_item = {}
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

    for _, logic in pairs(self._theme_to_logic) do
        logic:init()
    end
end

function MatchMgr:_on_start()
    MatchMgr.super._on_start(self)

    for _, logic in pairs(self._theme_to_logic) do
        logic:start()
    end
end

function MatchMgr:_on_stop()
    MatchMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()

    for _, logic in pairs(self._theme_to_logic) do
        logic:stop()
    end
end

function MatchMgr:_on_release()
    MatchMgr.super._on_release(self)

    for _, logic in pairs(self._theme_to_logic) do
        logic:release()
    end
end

function MatchMgr:_on_update()
    -- log_print("MatchMgr:_on_update")
    MatchMgr.super._on_update(self)

    for _, logic in pairs(self._theme_to_logic) do
        logic:update()
    end
end

function MatchMgr:_create_match_team(match_theme, match_key, ask_role_id, teammate_role_ids, extra_param)
    local ret = nil
    local logic = self:get_match_logic(match_theme)
    if logic then
        ret = logic:create_match_team(match_key, ask_role_id, teammate_role_ids, extra_param)
    end
    return ret
end

function MatchMgr:get_match_item(match_key)
    local ret = self._key_to_item[match_key]
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

    local error_num = Error_None
    repeat
        local match_item = self:get_match_item(msg.match_key)
        if match_item then
            error_num = Error.join_match.match_key_clash
            break
        end
        local sub_error_num, match_team = self:_create_match_team(msg.match_theme, msg.match_key, msg.role_id, msg.teammate_role_ids, msg.extra_param)
        if not sub_error_num then
            error_num = sub_error_num
            break
        end
        local match_item = MatchItem:new()
        match_item.match_theme = msg.match_theme
        match_item.match_key = msg.match_key
        match_item.match_team = match_team
        match_item.match_logic = self:get_match_logic(msg.match_theme)
        self._key_to_item[match_item.match_key] = match_item

        match_item.state = Match_Item_State.ask_teammate_accept_match
        for _, role_id in pairs(msg.teammate_role_ids) do
            --- 查询role所在game_server_key, 然后叫他们同意match
        end

    until true

    rpc_rsp:response(error_num)
end

---@param rpc_rsp RpcRsp
function MatchMgr:_on_rpc_quit_match(rpc_rsp, msg)
    log_print("MatchMgr:_on_rpc_quit_match", msg)
    self._key_to_item[msg.match_key] = nil
    rpc_rsp:response(Error_None)
end



