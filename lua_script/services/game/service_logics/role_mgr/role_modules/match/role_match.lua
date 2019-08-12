

RoleMatch = RoleMatch or class("RoleMatch", RoleModuleBase)
RoleMatch.Module_Name = "match"

function RoleMatch:ctor(role)
    RoleMatch.super.ctor(self, role, RoleMatch.Module_Name)
    self.match_times = 0
    self.join_match_type = Match_Type.none
    self.state = Role_Match_State.free
    self.match_client = nil
    self.match_session_id = nil
    self.match_cell_id = nil
end

function RoleMatch:init()
    RoleMatch.super.init(self)
    self.role:set_client_msg_process_fn(ProtoId.req_join_match, Functional.make_closure(self._on_msg_req_join_match, self))
end

function RoleMatch:init_from_db(db_ret)
    local db_info = db_ret[self.module_name] or {}
    local data_struct_version = db_info.data_struct_version or Data_Struct_Version_Match_Info
    if nil == db_info.data_struct_version or db_info.data_struct_version ~= data_struct_version then
        self:set_dirty()
    end
    self.data_struct_version = data_struct_version

    if GameRole.is_first_launch(db_ret) then
        -- self.match_times = 0
    else
        self.match_times = db_info.match_times
    end
end

function RoleMatch:pack_for_db(out_ret)
    local db_info = {}
    out_ret[self.module_name] = db_info
    db_info.data_struct_version = self.data_struct_version
    db_info.match_times = self.match_times
    return self.module_name, db_info
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
        self.match_client = SERVICE_MAIN:create_rpc_client(match_service_key)
        self.match_client:call(Functional.make_closure(self._on_rpc_cb_join_match, self),
        MatchRpcFn.join_match, self.role.role_id, msg.match_type)
    until true
    if Error_None ~= error_num then
        self.role:send_to_client(ProtoId.rsp_join_match, {
            match_type = msg.match_type,
            error_num = error_num,
        })
    end
end

function RoleMatch:_on_rpc_cb_join_match(rpc_error_num, error_num, match_session_id, match_type, match_cell_id)
    if Game_Role_State.in_game ~= self.role.state then
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
        if Role_Match_State.free ~= self.state then
            out_ms.error_num = Error.Join_Match.role_match_state_not_fit
            break
        end
        self.join_match_type = match_type
        self.match_session_id = match_session_id
        self.match_cell_id = match_cell_id
        self.state = Role_Match_State.matching
    until true
    self.role:send_to_client(ProtoId.rsp_join_match, out_msg)
end