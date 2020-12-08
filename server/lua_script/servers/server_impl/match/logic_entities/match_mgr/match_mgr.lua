
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
        local match_logic = MatchLogicSimpleFill:new(self, {
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
    local error_num, ret = Error_Unknown, nil
    local logic = self:get_match_logic(match_theme)
    if logic then
        ret = logic:create_match_team(match_key, ask_role_id, teammate_role_ids, extra_param)
        if ret then
            error_num = Error_None
        end
    end
    return error_num, ret
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
    local error_num = Error_None
    repeat
        local match_item = self:get_match_item(msg.match_key)
        if match_item then
            error_num = Error.join_match.match_key_clash
            break
        end

        local sub_error_num, match_team = self:_create_match_team(msg.match_theme, msg.match_key, msg.role_id, msg.teammate_role_ids, msg.extra_param)
        if Error_None ~= sub_error_num then
            error_num = sub_error_num
            break
        end

        local match_item = MatchItem:new()
        match_item.match_theme = msg.match_theme
        match_item.match_key = msg.match_key
        match_item.match_team = match_team
        match_item.match_logic = self:get_match_logic(msg.match_theme)
        match_item.role_replys = {}
        self._key_to_item[match_item.match_key] = match_item

        match_item.state = Match_Item_State.ask_teammate_accept_match
        for _, v in pairs(msg.teammate_role_ids) do
            local role_id = v
            self._rpc_svc_proxy:call_game_server(
                    Functional.make_closure(self._on_cb_ask_role_accept_match, self, match_item, role_id),
                    role_id, Rpc.game.method.ask_role_accept_match, role_id, msg)
        end
    until true

    log_print("MatchMgr:_handle_remote_call_join_match", error_num, msg)
    rpc_rsp:response(error_num)
end

---@param match_item MatchItem
function MatchMgr:_on_cb_ask_role_accept_match(match_item, role_id, rpc_error_num, error_num, is_accept)
    log_print("MatchMgr:_on_cb_ask_role_accept_match", role_id, rpc_error_num, error_num,  is_accept)
    if Match_Item_State.ask_teammate_accept_match ~=  match_item.state then
        return
    end

    local real_error_num = pick_error_num(rpc_error_num, error_num)
    if Error_None ~= real_error_num then
        match_item.role_replys[role_id] = false
    else
        match_item.role_replys[role_id] = is_accept
    end
    if not match_item.role_replys[role_id] then
        match_item.state = Match_Item_State.over
        for _, v in pairs(match_item.match_team.teammate_role_ids) do
            self._rpc_svc_proxy:call_game_server(nil, v, Rpc.game.method.notify_match_over, v, match_item.match_key)
        end
        self:remove_team(match_item.match_key)
    else
        if table.size(match_item.role_replys) == #match_item.match_team.teammate_role_ids then
            match_item.state = Match_Item_State.all_teammate_accept_match
            match_item.can_match = true
            match_item.role_replys = {}
            self:enter_match_pool(match_item.match_key)
            for _, v in pairs(match_item.match_team.teammate_role_ids) do
                self._rpc_svc_proxy:call_game_server(nil, v, Rpc.game.method.notify_matching, v, match_item.match_key)
            end
        end
    end
end

function MatchMgr:remove_team(match_key)
    self:leave_match_pool(match_key)
    local match_item = self._key_to_item[match_key]
    self._key_to_item[match_key] = nil
    if match_item then
        -- todo:
    end
end

function MatchMgr:enter_match_pool(match_key)
    local match_item = self._key_to_item[match_key]
    --
end

function MatchMgr:leave_match_pool(match_key)

end

---@param rpc_rsp RpcRsp
function MatchMgr:_on_rpc_quit_match(rpc_rsp, msg)
    log_print("MatchMgr:_on_rpc_quit_match", msg)
    -- local match_item = self._key_to_item[msg.match_key]
    self._key_to_item[msg.match_key] = nil
    rpc_rsp:response(Error_None)
end



