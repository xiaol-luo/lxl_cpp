_MatchRpcHandler = _MatchRpcHandler or {}

function RoleMgr:_setup_rpc_handler__match()
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_confirm_join_match, Functional.make_closure(_MatchRpcHandler._on_rpc_notify_confirm_join_match, self))
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_terminate_match, Functional.make_closure(_MatchRpcHandler._on_rpc_notify_confirm_join_match, self))
end

function _MatchRpcHandler._on_rpc_notify_confirm_join_match(role_mgr, rpc_rsp, role_id, session_id, match_room_id)
    local is_accept = true
    rpc_rsp:respone(Error_None, session_id, is_accept)
end

function _MatchRpcHandler._on_rpc_notify_terminate_match(role_mgr, rpc_rsp, role_id, session_id)
    rpc_rsp:respone(Error_None, session_id)
end




