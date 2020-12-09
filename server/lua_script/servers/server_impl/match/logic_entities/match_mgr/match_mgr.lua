
---@class MatchMgr:GameLogicEntity
MatchMgr = MatchMgr or class("MatchMgr", GameLogicEntity)

function MatchMgr:ctor(logics, logic_name)
    MatchMgr.super.ctor(self, logics, logic_name)
    ---@type MatchServiceMgr
    self.server = self.server
    ---@type table<Match_Theme, MatchItem>
    self._key_to_item = {}
    ---@type table<string, MatchLogicBase>
    self._theme_to_logic = {}
    ---@type table<string, boolean>
    self._quit_match_keys = {}

    self._key_to_match_game = {}
end

function MatchMgr:_on_init()
    MatchMgr.super._on_init(self)

    do
        local match_logic = SimpleFillMatchLogic:new(self, {
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
    MatchMgr.super._on_update(self)


    for _, logic in pairs(self._theme_to_logic) do
        logic:update()
        local ready_match_games = logic:pop_ready_match_games()
        if ready_match_games then
            local invalid_match_games = {}
            local valid_match_games = {}
            do -- 根据规则填充两个table
                for _ , match_game in pairs(ready_match_games) do
                    local all_team_ok = true
                    for _, match_camp in pairs(match_game.match_camps) do
                        for match_key, _ in pairs(match_camp.match_teams) do
                            if self._quit_match_keys[match_key] then
                                all_team_ok = false
                                break
                            end
                        end
                        if all_team_ok then
                            break
                        end
                    end
                    if not all_team_ok then
                        table.insert(invalid_match_games, match_game)
                    else
                        table.insert(valid_match_games, match_game)
                    end
                end
            end
            log_print("MatchMgr.super._on_update ", #invalid_match_games, #valid_match_games)
            for _, match_game in pairs(valid_match_games) do
                -- 合法的match_game， 给对应的match_item设置状态
                -- todo: 但实际上还需要加game_role确认的流程
                -- todo: 和room对接,申请room
                self._key_to_match_game[match_game.unique_key] = match_game
                for _, match_camp in pairs(match_game.match_camps) do
                    for match_key, _ in pairs(match_camp.match_teams) do
                        local match_item = self:get_match_item(match_key)
                        match_item.state = Match_Item_State.match_done
                    end
                end
            end
            for _, match_game in pairs(invalid_match_games) do
                -- 不合法的match_game，重新加入匹配
                for _, match_camp in pairs(match_game.match_camps) do
                    for match_key, _ in pairs(match_camp.match_teams) do
                        local match_item = self:get_match_item(match_key)
                        if match_item then
                            match_item.state = Match_Item_State.wait_enter_match_pool
                            self:enter_match_pool(match_key)
                        end
                    end
                end
            end
        end
    end

    if next(self._quit_match_keys) then
        self._quit_match_keys = {}
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
        self:remove_team(match_item.match_key)
        for _, v in pairs(match_item.match_team.teammate_role_ids) do
            self._rpc_svc_proxy:call_game_server(nil, v, Rpc.game.method.notify_match_over, v, match_item.match_key)
        end
    else
        if table.size(match_item.role_replys) == #match_item.match_team.teammate_role_ids then
            match_item.state = Match_Item_State.wait_enter_match_pool
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
        for _, v in pairs(match_item.match_team.teammate_role_ids) do
            self._rpc_svc_proxy:call_game_server(nil, v, Rpc.game.method.notify_match_over, v, match_item.match_key)
        end
    end
end

function MatchMgr:enter_match_pool(match_key)
    local match_item = self._key_to_item[match_key]
    if not match_item or Match_Item_State.wait_enter_match_pool ~= match_item.state then
        return false
    end
    local match_logic = self:get_match_logic(match_item.match_theme)
    if not match_logic then
        return false
    end
    local ret = match_logic:enter_match(match_item.match_team)
    if ret then
        match_item.state = Match_Item_State.matching
    end
    return ret
end

function MatchMgr:leave_match_pool(match_key)
    local match_item = self._key_to_item[match_key]
    if match_item then
        local match_logic = self:get_match_logic(match_item.match_theme)
        if match_logic then
            match_logic:leave_match(match_item.match_key)
        end
    end
end

---@param rpc_rsp RpcRsp
function MatchMgr:_on_rpc_quit_match(rpc_rsp, msg)
    local error_num = Error_None
    local match_item = self:get_match_item(msg.match_key)
    if match_item and Match_Item_State.match_done ~= match_item.state then
        self:remove_team(match_item.match_key)
        for _, v in pairs(match_item.match_team.teammate_role_ids) do
            self._rpc_svc_proxy:call_game_server(nil, v, Rpc.game.method.notify_match_over, v, match_item.match_key)
        end
        self._quit_match_keys[match_item.match_key] = true
    else
        error_num = Error.quit_match.can_not_quit_when_match_done
    end
    log_print("MatchMgr:_on_rpc_quit_match", error_num, msg, match_item and match_item.state)
    rpc_rsp:response(error_num)
end




