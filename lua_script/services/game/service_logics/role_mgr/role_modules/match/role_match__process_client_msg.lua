

function RoleMatch:init_process_client_msg()
    self.role:set_client_msg_process_fn(ProtoId.req_join_match, Functional.make_closure(self._on_msg_req_join_match, self))
end

function RoleMatch:_on_msg_req_join_match(pid, msg)
    local error_num = Error_None
    repeat
        if msg.match_type <= Match_Type.none or msg.match_type >= Match_Type.max then
            error_num = Error.Join_Match.invalid_match_type
            break
        end
        if Role_Match_State.free ~= self.state then
            error_num = Error.Join_Match.role_match_state_not_fit
            break
        end
        local match_service_key = SERVICE_MAIN.match_agent_mgr:pick_agent(msg.match_type, self.role)
        if not match_service_key then
            error_num = Error.Join_Match.no_valid_match_service
            break
        end
        self.state = Role_Match_State.joining_match
        self.match_type = msg.match_type
        self.match_client = SERVICE_MAIN:create_rpc_client(match_service_key)
        self.match_session_id = native.gen_uuid()
        self.match_client:call(Functional.make_closure(self._on_rpc_cb_join_match, self, self.match_session_id),
                MatchRpcFn.join_match, self.match_session_id, self.role.role_id, msg.match_type, {})
    until true
    if Error_None ~= error_num then
        self.role:send_to_client(ProtoId.rsp_join_match, {
            match_type = msg.match_type,
            error_num = error_num,
        })
    end
end

function RoleMatch:_on_rpc_cb_join_match(call_match_session_id, rpc_error_num, error_num, match_cell_id)
    if call_match_session_id ~= self.match_session_id then
        -- 中间不知道发生了什么，总之这个回调需要被忽略了
        return
    end
    local out_msg = {
        match_type = match_type,
        error_num = Error_None,
    }
    repeat
        if Error_None ~= rpc_error_num then
            out_msg.error_num = rpc_error_num
            break
        end
        if Error_None ~= error_num then
            out_msg.error_num = error_num
            break
        end
        if Role_Match_State.joining_match ~= self.state then
            out_ms.error_num = Error.Join_Match.role_match_state_not_fit
            break
        end
        self.state = Role_Match_State.matching
        self.match_cell_id = match_cell_id
    until true
    if Error_None ~= out_ms.error_num then
        self:clear_match_state()
    end
    self.role:send_to_client(ProtoId.rsp_join_match, out_msg)
end

