
MessLogic = MessLogic or class("MessLogic", ServiceLogic)

function MessLogic:ctor(logic_mgr, logic_name)
    MessLogic.super.ctor(self, logic_mgr, logic_name)
end

function MessLogic:init()
    MessLogic.super.init(self)

    local rpc_process_fns_map = {
        [MatchRpcFn.query_service_state] = self._on_rpc_query_service_state,
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

function MessLogic:_on_rpc_query_service_state(rpc_rsp)
    -- log_debug("MessLogic:_on_rpc_query_service_state")
    rpc_rsp:response()
end



