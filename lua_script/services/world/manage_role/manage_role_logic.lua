
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
    self.db_client:find_many(1, self.query_db, self.query_coll, { user_id=user_id, role_id=role_id }, function(db_ret)
        log_debug("get_role_digest db_ret %s", db_ret)
    end, find_opt)
end
