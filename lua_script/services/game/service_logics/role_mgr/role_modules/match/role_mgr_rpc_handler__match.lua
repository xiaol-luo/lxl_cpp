_MatchRpcHandler = _MatchRpcHandler or {}

function RoleMgr:_setup_rpc_handler__match()
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.confirm_join_match, Functional.make_closure())
end

function _MatchRpcHandler._on_rpc_confirm_join_match(role_mgr, rpc_rsp, role_id, token, match_cell_id, match_room_id)
    rpc_rsp:respone(Error_None)
end



