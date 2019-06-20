
ManageRoleLogic = ManageRoleLogic or class("ManageRoleLogic", ServiceLogic)

function ManageRoleLogic:ctor(logic_mgr, logic_name)
    ManageRoleLogic.super.ctor(self, logic_mgr, logic_name)
    self.rpc_mgr = self.service.rpc_mgr
    self.db_client = self.service.db_client
    self.query_db = self.service.query_db
    self.query_coll = "role"
end

function ManageRoleLogic:init()
    ManageRoleLogic.super.init(self)

    local rpc_process_fns_map = {
        [WorldRpcFn.get_role_digest] = self.get_role_digest,
        [WorldRpcFn.create_role] = self.create_role,
        [WorldRpcFn.launch_role] = self.launch_role,
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

function ManageRoleLogic:start()
    ManageRoleLogic.super.start(self)
end

function ManageRoleLogic:stop()
    ManageRoleLogic.super.stop(self)
end

function ManageRoleLogic:get_role_digest(rpc_rsp, user_id, role_id)
    log_debug("process_fns.get_role_digest %s %s", user_id, role_id)

    local find_opt = MongoOptFind:new()
    find_opt:set_max_time(5 * 1000)
    local filter = {}
    filter.user_id = user_id
    if role_id > 0 then
        filter.role_id = role_id
    end
    self.db_client:find_many(1, self.query_db, self.query_coll, filter, function(db_ret)
        log_debug("get_role_digest db_ret %s", db_ret)
        if 0 == db_ret.error_num then
            local ret = {}
            for _, v in pairs(db_ret.val) do
                table.insert(ret, { role_id=v.role_id })
            end
            rpc_rsp:respone(ret)
            return
        end
        rpc_rsp:report_error(string.format("error_num:%s, error_msg:%s", db_ret.error_num, db_ret.error_msg))
    end, find_opt)
end

function ManageRoleLogic:create_role(rpc_rsp, user_id)
    log_debug("ManageRoleLogic:create_role %s", user_id)
    if not user_id then
        rpc_rsp:report_error("user_id is nil")
        return
    end
    local role_id = self.service.db_uuid:apply(Service_Const.role_id)
    if not role_id then
        rpc_rsp:report_error("apply role id fail")
        return
    end
    local doc ={
        user_id = user_id,
        role_id = role_id,
    }
    local filter = {}
    filter.user_id = user_id
    self.db_client:count_document(1, self.query_db, self.query_coll, filter, function(db_ret)
        local Max_Role_Count = 3
        if 0 == db_ret.error_num and db_ret.matched_count < Max_Role_Count then
            self.db_client:insert_one(1, self.query_db, self.query_coll, doc, function(db_ret)
                log_debug("create role db_ret %s", db_ret)
                if 0 == db_ret.error_num then
                    rpc_rsp:respone(doc.role_id)
                else
                    rpc_rsp:report_error(string.format("error_num:%s, error_msg:%s", db_ret.error_num, db_ret.error_msg))
                end
            end)
        else
            rpc_rsp:report_error(string.format("already create role %s/%s", db_ret.matched_count, Max_Role_Count))
        end
    end)
end

ManageRoleLogic._Launch_Role_Error = {
    none = 0,
    no_valid_game_service = 1,
    launch_fail = 2,
}

function ManageRoleLogic:launch_role(rpc_rsp, role_id)
    log_debug("world ManageRoleLogic:launch_role %s", role_id)
    local error_num = ManageRoleLogic._Launch_Role_Error.none
    local game_service_key = ""
    repeat
        local service_info = self.service.zone_net:rand_service(Service_Const.Game)
        if not service_info then
            error_num = ManageRoleLogic._Launch_Role_Error.no_valid_game_service
            break
        end
        self.service.rpc_mgr:call(
                Functional.make_closure(self._rpc_rsp_launch_role, self, role_id, service_info.key, rpc_rsp),
                service_info.key, GameRpcFn.launch_role, role_id)
    until true
    if ManageRoleLogic._Launch_Role_Error.none ~= error_num then
        rpc_rsp:respone(error_num, game_service_key)
    end
end

function ManageRoleLogic:_rpc_rsp_launch_role(role_id, to_game_service_key, rpc_rsp, rpc_error_num, launch_error_num)
    log_debug("xxxxxxxxxxxxxxxx ManageRoleLogic:_rpc_rsp_launch_role %s %s", rpc_error_num, launch_error_num)
    local error_num = ManageRoleLogic._Launch_Role_Error.none
    if Rpc_Error.None ~= rpc_error_num or 0 ~= launch_error_num then
        error_num = ManageRoleLogic._Launch_Role_Error.launch_fail
    end
    rpc_rsp:respone(error_num, to_game_service_key)
end
