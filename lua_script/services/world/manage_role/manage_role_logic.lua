
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
        get_role_digest = self.get_role_digest,
        create_role = self.create_role,
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
    if #role_id > 0 then
        filter.role_id = role_id
    end
    self.db_client:find_many(1, self.query_db, self.query_coll, filter, function(db_ret)
        log_debug("get_role_digest db_ret %s", db_ret)
        if 0 == db_ret.err_num then
            local ret = {}
            for _, v in pairs(db_ret.val) do
                table.insert(ret, { role_id=v.role_id })
            end
            rpc_rsp:respone(ret)
            return
        end
        rpc_rsp:report_error(string.format("error_num:%s, error_msg:%s", db_ret.err_num, db_ret.err_msg))
    end, find_opt)
end

function ManageRoleLogic:create_role(rpc_rsp, user_id)
    log_debug("ManageRoleLogic:create_role %s", user_id)
    if not user_id then
        rpc_rsp:report_error("user_id is nil")
        return
    end
    local doc ={
        user_id = user_id,
        role_id = native.gen_uuid(),
    }
    local filter = {}
    filter.user_id = user_id
    self.db_client:count_document(1, self.query_db, self.query_coll, filter, function(db_ret)
        local Max_Role_Count = 3
        if 0 == db_ret.err_num and db_ret.matched_count < Max_Role_Count then
            self.db_client:insert_one(1, self.query_db, self.query_coll, doc, function(db_ret)
                log_debug("create role db_ret %s", db_ret)
                if 0 == db_ret.err_num then
                    rpc_rsp:respone(doc.role_id)
                else
                    rpc_rsp:report_error(string.format("error_num:%s, error_msg:%s", db_ret.err_num, db_ret.err_msg))
                end
            end)
        else
            rpc_rsp:report_error(string.format("already create role %s/%s", db_ret.matched_count, Max_Role_Count))
        end
    end)
end
