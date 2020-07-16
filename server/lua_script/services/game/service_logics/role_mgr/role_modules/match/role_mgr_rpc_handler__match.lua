
function RoleMgr:_setup_rpc_handler__match()
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_confirm_join_match, Functional.make_closure(self._on_rpc_notify_confirm_join_match, self))
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_terminate_match, Functional.make_closure(self._on_rpc_notify_terminate_match, self))
    self.rpc_mgr:set_req_msg_process_fn(GameRpcFn.notify_match_succ, Functional.make_closure(self._on_rpc_notify_match_succ, self))
end

function RoleMgr:_on_rpc_notify_confirm_join_match(rpc_rsp, role_id, session_id, match_room_id)
    local is_accept = true
    repeat
        local role = self:get_in_game_role(role_id)
        if not role then
            is_accept = false
            break
        end
        if Role_Match_State.matching ~= role.match.state then
            is_accept = false
            break
        end
        if not role.match.match_session_id or role.match.match_session_id ~= session_id then
            is_accept = false
            break
        end
        role.match.match_cell_id = match_room_id
        role.match.state = Role_Match_State.wait_enter_room
        role.match:sync_match_state()
    until true
    rpc_rsp:response(is_accept)
end

function RoleMgr:_on_rpc_notify_terminate_match(rpc_rsp, role_id, session_id)
    rpc_rsp:response()
    local role = self:get_in_game_role(role_id)
    if role then
        if role.match.session_id and role.match.session_id == session_id then
            role.match:clear_match_state()
            role.match:sync_match_state()
        end
    end
end

function RoleMgr:_on_rpc_notify_match_succ(rpc_rsp, role_id, session_id, join_match_type, room_service_key, room_id)
    rpc_rsp:response()
    local role = self:get_in_game_role(role_id)
    if role then
        if role.match.match_session_id and role.match.match_session_id == session_id then
            assert(Role_Match_State.wait_enter_room == role.match.state)
            role.match.state = Role_Match_State.finish
            role.match:sync_match_state()
            role.room:bind_room(join_match_type, room_service_key, role.match.match_session_id, room_id)
            role.match:clear_match_state()
            role.match:sync_match_state()
        end
    end
end





