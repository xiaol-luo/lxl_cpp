
RoleMgr = RoleMgr or class("RoleMgr", ServiceLogic)

function RoleMgr:ctor(logic_mgr, logic_name)
    RoleMgr.super.ctor(self, logic_mgr, logic_name)
    self._id_to_role = {}
end

function RoleMgr:init()
    RoleMgr.super.init(self)

    local rpc_process_fns_map = {
    }

    local rpc_co_process_fns_map = {

    }
    for fn_name, fn in pairs(rpc_process_fns_map) do
        self.service.rpc_mgr:set_req_msg_process_fn(fn_name, Functional.make_closure(fn, self))
    end
    for fn_name, fn in pairs(rpc_co_process_fns_map) do
        self.service.rpc_mgr:set_req_msg_coroutine_process_fn(fn_name, Functional.make_closure(fn, self))
    end
end

function RoleMgr:start()
    RoleMgr.super.start(self)
end

function RoleMgr:stop()
    RoleMgr.super.stop(self)
end

function RoleMgr:get_role(role_id)
    return self._id_to_role[role_id]
end

function RoleMgr:add_role(role_id, extra_data) end