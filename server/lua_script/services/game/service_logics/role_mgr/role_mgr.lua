
RoleMgr = RoleMgr or class("RoleMgr", ServiceLogic)

function RoleMgr:ctor(logic_mgr, logic_name)
    RoleMgr.super.ctor(self, logic_mgr, logic_name)
    self.rpc_mgr = self.service.rpc_mgr
    self.db_client = self.service.db_client
    self.query_db = self.service.query_db
    self.query_coll = "role"
    self._timer_proxy = nil

    self._id_to_role = {}
    self._next_save_role_id = nil
    self._event_proxy = nil
end

function RoleMgr:init()
    RoleMgr.super.init(self)
    self._timer_proxy = TimerProxy:new()
    self.event_proxy = self.service:create_event_proxy()

    local rpc_process_fns_map = {
        [GameRpcFn.launch_role] = self.luanch_role,
        [GameRpcFn.client_change] = self.client_change,
        [GameRpcFn.release_role] = self.release_role,
    }

    local rpc_co_process_fns_map = {

    }
    for fn_name, fn in pairs(rpc_process_fns_map) do
        self.rpc_mgr:set_req_msg_process_fn(fn_name, Functional.make_closure(fn, self))
    end
    for fn_name, fn in pairs(rpc_co_process_fns_map) do
        self.rpc_mgr:set_req_msg_coroutine_process_fn(fn_name, Functional.make_closure(fn, self))
    end

    self:_setup_client_mgs_process_fn()
    self:_setup_event_handler()
    self:_setup_rpc_handler()
end

function RoleMgr:start()
    RoleMgr.super.start(self)
    self._timer_proxy:firm(Functional.make_closure(self._on_tick, self), 100, -1)
    log_debug("RoleMgr:start")
end

function RoleMgr:stop()
    RoleMgr.super.stop(self)
    self._timer_proxy:release_all()
    self.event_proxy:release_all()
end

function RoleMgr:_on_tick()
    local Save_Role_Max_Count_Per_Tick = 100
    local to_save_roles = {}
    if self._next_save_role_id then
        local role = self._id_to_role[self._next_save_role_id]
        if not role then
            self._next_save_role_id = nil
        else
            if role:is_need_save() then
                table.insert(to_save_roles, role)
            end
        end
    end
    local try_times = 0
    repeat
        try_times = try_times + 1
        local role = nil
        self._next_save_role_id, role = next(self._id_to_role, self._next_save_role_id)
        if role then
            if role:is_need_save() then
                table.insert(to_save_roles, role)
            end
        end
    until nil == self._next_save_role_id or #to_save_roles >= Save_Role_Max_Count_Per_Tick
    for _, role in ipairs(to_save_roles) do
        role:save(self.db_client, self.query_db, self.query_coll)
    end
end

function RoleMgr:get_role(role_id)
    return self._id_to_role[role_id]
end

function RoleMgr:get_in_game_role(role_id)
    local ret = nil
    local role = self._id_to_role[role_id]
    if role and Game_Role_State.in_game == role.state then
        ret = role
    end
    return ret
end

function RoleMgr:remove_role(role_id)
    if not self._next_save_role_id then
        if self._next_save_role_id == role_id then
            self._next_save_role_id = next(self._id_to_role, self._next_save_role_id)
        end
    end
    self._id_to_role[role_id] = nil
end

function RoleMgr:luanch_role(rpc_rsp, role_id, world_role_session_id)
    log_debug("RoleMgr:luanch_role %s %s", role_id, type(role_id))
    local role = self:get_role(role_id)
    if not role then
        role = GameRole:new(role_id)
        role:init()
        role.world_client = self.service:create_rpc_client(rpc_rsp.from_host)
        self._id_to_role[role_id] = role
    end
    if Game_Role_State.load_from_db == role.state then
        rpc_rsp:response(Error.Launch_Role.loading_from_db)
        return
    end
    if Game_Role_State.in_error == role.state then
        rpc_rsp:response(Error.Launch_Role.game_role_state_in_error)
        return
    end
    if Game_Role_State.in_game == role.state then
        role:set_launch_sec()
        rpc_rsp:response(Error_None)
        return
    end
    if Game_Role_State.free == role.state then
        local filter = {
            role_id = role_id,
        }
        self.db_client:find_one(role.db_hash, self.query_db, self.query_coll, filter,
                Functional.make_closure(self._db_rsp_launch_role, self, rpc_rsp, role_id))
        role.state = Game_Role_State.load_from_db
    end
end

function RoleMgr:_db_rsp_launch_role(rpc_rsp, role_id, db_ret)
    log_debug("RoleMgr:_db_rsp_launch_role %s", role_id)
    local role = self:get_role(role_id)
    if not role or Game_Role_State.load_from_db ~= role.state then
        rpc_rsp:response(Error.Launch_Role.unknown)
    end
    if 0 ~= db_ret.error_num or db_ret.matched_count <= 0 then
        role.state = Game_Role_State.in_error
        self:remove_role(role_id)
        rpc_rsp:response(Error.Launch_Role.query_db_fail)
        return
    end
    local db_data = db_ret.val["0"]
    if db_data.role_id ~= role.role_id then
        rpc_rsp:response(Error.Launch_Role.unknown)
        log_error("RoleMgr:_db_rsp_launch_role role_id not match %s != %s", db_data.role_id, role.role_id)
        return
    end
    role:init_from_db(db_data)
    role.state = Game_Role_State.in_game
    rpc_rsp:response(Error_None, role_id)
    if role:is_need_save() then
        role:save(self.db_client, self.query_db, self.query_coll)
    end
end


function RoleMgr:client_change(rpc_rsp, role_id, is_disconnect, gate_service_key, gate_client_netid)
    log_debug("RoleMgr:client_change %s %s %s %s", role_id, is_disconnect, gate_service_key, gate_client_netid)
    rpc_rsp:response(Error_None)
    local role = self:get_role(role_id)
    if role then
        if is_disconnect then
            role.gate_client = nil
            role.gate_client_netid = nil
        else
            role.gate_client = self.service:create_rpc_client(gate_service_key)
            role.gate_client_netid = gate_client_netid
        end
    end
end


function RoleMgr:release_role(rpc_rsp, role_id)
    log_debug("RoleMgr:release_role %s", role_id)
    rpc_rsp:response()
    local role = self:get_role(role_id)
    if role then
        if role:is_dirty() then
            role:save(self.db_client, self.query_db, self.query_coll)
        end
    end
    self:remove_role(role_id)
end

