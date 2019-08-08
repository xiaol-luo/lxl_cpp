
MatchMgr = MatchMgr or class("MatchMgr", ServiceLogic)

function MatchMgr:ctor(logic_mgr, logic_name)
    MatchMgr.super.ctor(self, logic_mgr, logic_name)
end

function MatchMgr:init()
    MatchMgr.super.init(self)

    local rpc_process_fns_map = {
        [MatchRpcFn.join_match] = self._on_rpc_join_match,
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

function MatchMgr:start()
    MatchMgr.super.start(self)
end

function MatchMgr:stop()
    MatchMgr.super.stop(self)
end

function MatchMgr:_on_rpc_join_match(rpc_rsp, role_id, join_match_type)
    rpc_rsp:respone(Error_None, {
        token = native.gen_uuid()
    })
end