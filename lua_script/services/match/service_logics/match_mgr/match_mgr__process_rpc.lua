

function MatchMgr:init_process_rpc_handler()

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


function MatchMgr:_on_rpc_join_match(rpc_rsp, match_session_id, role_id, join_match_type, extra_data)
    local role_mgr = self.service.role_mgr
    local role = role_mgr:get_role(role_id)
    if role then
        rpc_rsp:respone(Error.Join_Match.remote_is_matching)
        return
    end

    local error_num, match_cell = self:solo_join(join_match_type, role_id, extra_data)
    local match_cell_id = nil
    if Error_None == error_num then
        match_cell_id = match_cell.cell_id
        role = role_mgr:get_role(role_id)
        assert(role)
        role.game_client = self.service:create_rpc_client(rpc_rsp.from_host)
        role.game_session_id = match_session_id
    end
    rpc_rsp:respone(error_num, match_cell_id)
end