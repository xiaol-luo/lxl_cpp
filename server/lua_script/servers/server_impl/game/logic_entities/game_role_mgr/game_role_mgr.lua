
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
    self._id_to_role = {}

    self._next_save_role_id = nil
    self._wait_launch_role_rpc_rsps = {}
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
end

function GameRoleMgr:_on_stop()
    GameRoleMgr.super._on_stop(self)
end

function GameRoleMgr:_on_release()
    GameRoleMgr.super._on_release(self)
end

function GameRoleMgr:_on_update()    -- log_print("GameRoleMgr:_on_update")
end

---@param role_id number
---@return GameRole
function GameRoleMgr:get_role(role_id)
    return self._id_to_role[role_id]
end

---@param role_id number
---@return GameRole
function GameRoleMgr:get_role_in_game(role_id)
    local ret = nil
    local role = self._id_to_role[role_id]
    if role and Game_Role_State.in_game then
        ret = role
    end
    return ret
end

function GameRoleMgr:remove_role(role_id)
    if nil ~= role_id then
        if not self._next_save_role_id then
            if self._next_save_role_id == role_id then
                self._next_save_role_id = next(self._id_to_role, self._next_save_role_id)
            end
        end
        self._id_to_role[role_id] = nil
    end
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_launch_role(rpc_rsp, user_id, role_id)
    local game_role = self:get_role(role_id)
    if not game_role then
        game_role = GameRole:new(self, user_id, role_id)
        game_role:init()
        self._id_to_role[role_id] = game_role
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
        rpc_rsp:respone(error_num)
        return
    end

    if Game_Role_State.in_game == role_state then
        rpc_rsp:respone(Error_None)
        return
    end

    if Game_Role_State.load_from_db == role_state then
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
        rpc_rsp:respone(error_num)
    end
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_change_gate_client(rpc_rsp, role_id, is_disconnect, gate_server_key, gate_netid)
    local game_role = self:get_role_in_game(role_id)
    if not game_role then
        rpc_rsp:respone(Error.change_game_role_gate_client.role_not_exist)
        return
    end
    if is_disconnect then
        game_role:set_gate(nil, nil)
    else
        game_role:set_gate(gate_server_key, gate_netid)
    end
    rpc_rsp:respone(Error_None)
end

---@param rpc_rsp RpcRsp
function GameRoleMgr:_handle_remote_call_release_role(rpc_rsp, role_id)
    local game_role = self:get_role_in_game(role_id)
    if not game_role then
        rpc_rsp:respone(Error.release_game_role.role_not_exist)
        return
    end
    if game_role:is_dirty() then
        game_role:save_to_db(self._db_client, self._query_db_name, self._query_coll_name)
    end
    self:remove_role(role_id)
    rpc_rsp:respone(Error_None)
end

