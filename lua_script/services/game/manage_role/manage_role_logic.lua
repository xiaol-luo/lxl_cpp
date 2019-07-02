
ManageRoleLogic = ManageRoleLogic or class("ManageRoleLogic", ServiceLogic)

function ManageRoleLogic:ctor(logic_mgr, logic_name)
    ManageRoleLogic.super.ctor(self, logic_mgr, logic_name)
    self.rpc_mgr = self.service.rpc_mgr
    self.db_client = self.service.db_client
    self.query_db = self.service.query_db
    self.query_coll = "role"

    self.id_to_role = {}
end

function ManageRoleLogic:init()
    ManageRoleLogic.super.init(self)

    local rpc_process_fns_map = {
        [GameRpcFn.launch_role] = self.luanch_role,
        [GameRpcFn.client_quit] = self.client_quit,
    }

    local rpc_co_process_fns_map = {

    }
    for fn_name, fn in pairs(rpc_process_fns_map) do
        self.rpc_mgr:set_req_msg_process_fn(fn_name, Functional.make_closure(fn, self))
    end
    for fn_name, fn in pairs(rpc_co_process_fns_map) do
        self.rpc_mgr:set_req_msg_coroutine_process_fn(fn_name, Functional.make_closure(fn, self))
    end
end

function ManageRoleLogic:get_role(role_id)
    return self.id_to_role[role_id]
end

function ManageRoleLogic:luanch_role(rpc_rsp, role_id)
    log_debug("ManageRoleLogic:luanch_role %s %s", role_id, type(role_id))
    local role = self:get_role(role_id)
    if not role then
        role = GameRole:new(role_id)
        self.id_to_role[role_id] = role
    end
    if Game_Role_State.load_from_db == role.state then
        rpc_rsp:respone(Enum_Error.Launch_Role.loading_from_db)
        return
    end
    if Game_Role_State.in_error == role.state then
        rpc_rsp:respone(Enum_Error.Launch_Role.in_error)
        return
    end
    if Game_Role_State.in_game == role.state then
        rpc_rsp:respone(Error_None)
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

function ManageRoleLogic:_db_rsp_launch_role(rpc_rsp, role_id, db_ret)
    log_debug("ManageRoleLogic:_db_rsp_launch_role %s %s", role_id, db_ret)
    local role = self:get_role(role_id)
    if role and Game_Role_State.load_from_db == role.state then
        if 0 ~= db_ret.error_num or db_ret.matched_count <= 0 then
            role.state = Game_Role_State.in_error
            self.id_to_role[role_id] = nil
            rpc_rsp:respone(Enum_Error.Launch_Role.db_query_fail)
            return
        end
        local db_data = db_ret.val["0"]
        log_debug("sssssssssssssssss %s %s %s", type(db_data.role_id), type(role.role_id), role_id)
        assert(db_data.role_id == role.role_id)
        role.state = Game_Role_State.in_game
        role:init_from_db(db_data)
        rpc_rsp:respone(Error_None, role_id)
        local opt = MongoOptFindOneAndUpdate:new()
        opt:set_projection({ last_access_time = true })
        local update_doc = {
            ["$set"] = { last_launch_sec = logic_sec() }
        }
        self.db_client:find_one_and_update(role.db_hash, self.query_db, self.query_coll,
                { role_id = role_id }, update_doc, function(ret)
                    log_debug("-------------------- %s", ret)
                end, opt)
    else
        rpc_rsp:respone(Enum_Error.Launch_Role.unknown)
    end
end

function ManageRoleLogic:client_quit(role_id)

end

