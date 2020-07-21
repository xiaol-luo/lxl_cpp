
---@class GameRoleMgr:LogicEntity
GameRoleMgr = GameRoleMgr or class("GameRoleMgr", LogicEntity)

function GameRoleMgr:ctor(logic_svc, logic_name)
    GameRoleMgr.super.ctor(self, logic_svc, logic_name)
    ---@type GameServer
    self.server = self.server
    ---@type OnlineWorldShadow
    self._online_world_shadow = self.server.online_world_shadow
    ---@type MongoClient
    self._db_client = nil
    self._query_db_name = self.server.zone_name
    self._query_coll_name = Const.mongo.collection_name.role
    ---@type table<number, GameRole>
    self._id_to_roles = {}

    self._next_save_role_id = nil
    self._wait_launch_role_rpc_rsps = {}

    self._online_world_shadow_aprted_release_all_roles_tid = nil

    self._check_match_world_roles_last_sec = 0
end

function GameRoleMgr:_on_init()
    GameRoleMgr.super._on_init(self)
    ---@type MongoServerConfig
    local db_setting = self.server.mongo_setting_game
    self._db_client = MongoClient:new(db_setting.thread_num, db_setting.host, db_setting.auth_db,  db_setting.user, db_setting.pwd)
end

function GameRoleMgr:_on_start()
    GameRoleMgr.super._on_start(self)

    if not self._db_client:start() then
        self:set_error(-1, "GameRoleMgr:_on_start start mongo client fail")
        return
    end

    self:get_role(1)

    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.launch_role, Functional.make_closure(self._handle_remote_call_launch_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.change_gate_client, Functional.make_closure(self._handle_remote_call_change_gate_client, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.release_role, Functional.make_closure(self._handle_remote_call_release_role, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.bind_world, Functional.make_closure(self._handle_remote_call_bind_world, self))
    self._rpc_svc_proxy:set_remote_call_handle_fn(Rpc.game.method.check_match_game_roles, Functional.make_closure(self._handle_remote_call_check_match_game_roles, self))

    self._event_binder:bind(self._online_world_shadow, World_Online_Event.adjusting_version_state_change,
            Functional.make_closure(self._on_event_adjusting_version_state_change, self))
    self._event_binder:bind(self._online_world_shadow, World_Online_Event.shadow_parted_state_change,
            Functional.make_closure(self._on_event_shadow_parted_state_change, self))
end

function GameRoleMgr:_on_stop()
    GameRoleMgr.super._on_stop(self)
end

function GameRoleMgr:_on_release()
    GameRoleMgr.super._on_release(self)
end

function GameRoleMgr:_on_update()
    local now_sec = logic_sec()
    self:_check_match_world_roles(now_sec)
end

---@param role_id number
---@return GameRole
function GameRoleMgr:get_role(role_id)
    return self._id_to_roles[role_id]
end

---@param role_id number
---@return GameRole
function GameRoleMgr:get_role_in_game(role_id)
    local ret = nil
    local role = self._id_to_roles[role_id]
    if role and Game_Role_State.in_game then
        ret = role
    end
    return ret
end

function GameRoleMgr:remove_role(role_id)
    if nil ~= role_id then
        if not self._next_save_role_id then
            if self._next_save_role_id == role_id then
                self._next_save_role_id = next(self._id_to_roles, self._next_save_role_id)
            end
        end
        self._id_to_roles[role_id] = nil
    end
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_launch_role(rpc_rsp, user_id, role_id)
    if self._online_world_shadow:is_parted() then
        rpc_rsp:response(Error_Server_Online_Shadow_Parted)
        return
    end
    if self._online_world_shadow:is_adjusting_version() then
        rpc_rsp:response(Error_Consistent_Hash_Adjusting)
        return
    end

    local game_role = self:get_role(role_id)
    if not game_role then
        game_role = GameRole:new(self, user_id, role_id)
        game_role:init()
        self._id_to_roles[role_id] = game_role
    end

    local role_state = game_role:get_state()
    local error_num = Error_None

    repeat
        if user_id ~= game_role:get_user_id() then
            error_num = Error.launch_role.game_role_user_id_mismatch
            break
        end
        if Game_Role_State.in_error == role_state then
            error_num = Error.launch_role.game_role_in_error_state
            break
        end
    until true
    if Error_None ~= error_num then
        rpc_rsp:response(error_num)
        return
    end

    if Game_Role_State.in_game == role_state then
        game_role:set_world_server_key(rpc_rsp.from_host)
        rpc_rsp:response(Error_None)
        return
    end

    if Game_Role_State.load_from_db == role_state then
        game_role:set_world_server_key(rpc_rsp.from_host)
        self._wait_launch_role_rpc_rsps[role_id] = self._wait_launch_role_rpc_rsps[role_id] or {}
        local wait_rpc_rsps = self._wait_launch_role_rpc_rsps[role_id]
        table.insert(wait_rpc_rsps, rpc_rsp)
        return
    end

    if Game_Role_State.free == role_state then
        self._wait_launch_role_rpc_rsps[role_id] = self._wait_launch_role_rpc_rsps[role_id] or {}
        local wait_rpc_rsps = self._wait_launch_role_rpc_rsps[role_id]
        table.insert(wait_rpc_rsps, rpc_rsp)

        local db_filter = {
            role_id = role_id,
            user_id = user_id,
        }
        self._db_client:find_one(role_id, self._query_db_name, self._query_coll_name, db_filter,
            Functional.make_closure(self._db_rsp_launch_role, self, role_id)
        )
        game_role:set_state(Game_Role_State.load_from_db)
        game_role:set_world_server_key(rpc_rsp.from_host)
        return
    end
end

function GameRoleMgr:_db_rsp_launch_role(role_id, db_ret)
    local error_num = Error_None
    repeat
        local game_role = self:get_role(role_id)
        if not game_role or Game_Role_State.load_from_db ~= game_role:get_state() then
            error_num = Error_Unknown
            break
        end
        if Error_None ~= db_ret.error_num then
            error_num = Error_Mongo_Opera_Fail
            break
        end
        if db_ret.matched_count <= 0 then
            error_num = Error.launch_role.game_role_not_find_in_db
            break
        end
        local db_data = db_ret.val["0"]
        local init_ret = game_role:init_from_db(db_data)
        if not init_ret then
            error_num = Error.launch_role.game_role_init_from_db_fail
            game_role:set_state(Game_Role_State.in_error)
            self:remove_role(role_id)
            break
        end
        game_role:set_state(Game_Role_State.in_game)
    until true

    local wait_rpc_rsps = self._wait_launch_role_rpc_rsps[role_id]
    self._wait_launch_role_rpc_rsps[role_id] = nil
    for _, rpc_rsp in ipairs(wait_rpc_rsps or {}) do
        rpc_rsp:response(error_num)
    end
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_change_gate_client(rpc_rsp, role_id, is_disconnect, gate_server_key, gate_netid)
    local game_role = self:get_role_in_game(role_id)
    if not game_role then
        rpc_rsp:response(Error.change_game_role_gate_client.role_not_exist)
        return
    end
    if is_disconnect then
        game_role:set_gate(nil, nil)
    else
        game_role:set_gate(gate_server_key, gate_netid)
    end
    rpc_rsp:response(Error_None)
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_release_role(rpc_rsp, role_id)
    local game_role = self:get_role_in_game(role_id)
    if not game_role then
        rpc_rsp:response(Error.release_game_role.role_not_exist)
        return
    end
    game_role:check_and_save(self._db_client, self._query_db_name, self._query_coll_name)
    self:remove_role(role_id)
    rpc_rsp:response(Error_None)
end

function GameRoleMgr:_handle_remote_call_bind_world(rpc_rsp, role_id)
    local game_role = self:get_role_in_game(role_id)
    if not game_role then
        rpc_rsp:response(Error.game_role_bind_world.role_not_exist)
        return
    end
    game_role:set_world_server_key(rpc_rsp.from_host)
    rpc_rsp:response(Error_None)
end

function GameRoleMgr:_handle_remote_call_check_match_game_roles(rpc_rsp, role_ids)
    local mismatch_role_ids = {}
    for _, role_id in pairs(role_ids) do
        local game_role = self._id_to_roles[role_id]
        if not game_role or game_role:get_world_server_key() ~= rpc_rsp.from_host then
            table.insert(mismatch_role_ids, role_id)
        end
    end
    rpc_rsp:response(Error_None, mismatch_role_ids)
end

function GameRoleMgr:_on_event_adjusting_version_state_change(is_adjusting)
    if is_adjusting then
        local to_remove_role = {}
        for role_id, game_role in pairs(self._id_to_roles) do
            if Game_Role_State.in_game ~= game_role:get_state() then
                to_remove_role[role_id] = game_role
            end
        end
        for role_id, game_role in pairs(to_remove_role) do
            game_role:check_and_save(self._db_client, self._query_db_name, self._query_coll_name)
            self:remove_role(role_id)
        end
    else
        local to_remove_role = {}
        for role_id, game_role in pairs(self._id_to_roles) do
            local want_world_server_key = self._online_world_shadow:cal_server_address(role_id)
            if want_world_server_key ~= game_role:get_world_server_key() then
                to_remove_role[role_id] = game_role
            end
        end
        for role_id, game_role in pairs(to_remove_role) do
            game_role:check_and_save(self._db_client, self._query_db_name, self._query_coll_name)
            self:remove_role(role_id)
        end
        -- todo: 广播被踢掉的人
        local removed_role_ids = table.keys(to_remove_role)
        for _, world_server_key in pairs(self.server.peer_net:get_role_server_keys(Server_Role.World)) do
            self._rpc_svc_proxy:call(nil, world_server_key, Rpc.world.method.notify_release_game_roles, removed_role_ids)
        end
    end
end

function GameRoleMgr:_on_event_shadow_parted_state_change(is_parted)
    self:_try_release_all_roles_for_online_world_shadow_parted(is_parted)
end

function GameRoleMgr:_try_release_all_roles_for_online_world_shadow_parted(need_release)
    if self._online_world_shadow_aprted_release_all_roles_tid then
        self._timer_proxy:remove(self._online_world_shadow_aprted_release_all_roles_tid)
        self._online_world_shadow_aprted_release_all_roles_tid = nil
    end
    if need_release then
        self._online_world_shadow_aprted_release_all_roles_tid = self._timer_proxy:delay(function ()
            self._online_world_shadow_aprted_release_all_roles_tid = nil
            local role_ids = {}
            for role_id, game_role in pairs(self._id_to_roles) do
                game_role:check_and_save(self._db_client, self._query_db_name, self._query_coll_name)
                table.insert(role_ids, role_id)
            end
            self._id_to_roles = {}
            self._next_save_role_id = nil
            -- todo: 广播被踢掉的人
            for _, world_server_key in pairs(self.server.peer_net:get_role_server_keys(Server_Role.World)) do
                self._rpc_svc_proxy:call(nil, world_server_key, Rpc.world.method.notify_release_game_roles, role_ids)
            end
        end, Game_Role_Const.after_n_secondes_release_all_role * MICRO_SEC_PER_SEC)
    end
end

function GameRoleMgr:_check_match_world_roles(now_sec)
    if now_sec - self._check_match_world_roles_last_sec < Game_Role_Const.check_match_world_role_span_sec then
        return
    end
    self._check_match_world_roles_last_sec = now_sec
    local world_to_role_ids = {}
    for role_id, game_role in pairs(self._id_to_roles) do
        if Game_Role_State.in_game == game_role:get_state() then
            local world_server_key = game_role:get_world_server_key()
            local role_ids = world_to_role_ids[world_server_key]
            if not role_ids then
                role_ids = {}
                world_to_role_ids[world_server_key] = role_ids
            end
            table.insert(role_ids, role_id)
            if #role_ids >= Game_Role_Const.check_match_world_role_count_per_rpc_query then
                self:_do_check_match_world_roles(1, world_server_key, role_ids)
                world_to_role_ids[world_server_key] = {}
            end
        end
    end
    for world_server_key, role_ids in pairs(world_to_role_ids) do
        if #role_ids > 0 then
            self:_do_check_match_world_roles(1, world_server_key, role_ids)
        end
    end
end

function GameRoleMgr:_do_check_match_world_roles(try_times, world_server_key, role_ids)
    self._rpc_svc_proxy:call(function(rpc_error_num, logic_error_num, mismatch_role_ids)
        local release_role_ids = mismatch_role_ids
        if Error_None ~= pick_error_num(rpc_error_num, logic_error_num) then
            local Max_Try_Times = 3
            local Delay_Try_Ms = 2000
            if try_times <= Max_Try_Times then
                self._timer_proxy:delay(Functional.make_closure(self._do_check_match_world_roles,
                        self, try_times + 1, world_server_key, role_ids), Delay_Try_Ms)
                return
            else
                release_role_ids = role_ids
            end
        end
        local removed_role_ids = {}
        if release_role_ids then
            for _, role_id in pairs(release_role_ids) do
                local game_role = self._id_to_roles[role_id]
                if game_role then
                    game_role:check_and_save(self._db_client, self._query_db_name, self._query_coll_name)
                    self:remove_role(role_id)
                    table.insert(removed_role_ids, role_id)
                end
            end
            -- todo: 广播被踢掉的人
            for _, world_server_key in pairs(self.server.peer_net:get_role_server_keys(Server_Role.World)) do
                self._rpc_svc_proxy:call(nil, world_server_key, Rpc.world.method.notify_release_game_roles, removed_role_ids)
            end
        end
    end, world_server_key, Rpc.game.method.check_match_game_roles, role_ids)
end