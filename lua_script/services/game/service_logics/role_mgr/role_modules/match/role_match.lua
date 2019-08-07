

RoleMatch = RoleMatch or class("RoleMatch", RoleModuleBase)
RoleMatch.Module_Name = "match"

function RoleMatch:ctor(role)
    RoleMatch.super.ctor(self, role, RoleMatch.Module_Name)
    self.match_times = 0
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
    log_debug("RoleMatch:pack_for_db")
    local db_info = {}
    out_ret[self.module_name] = db_info
    db_info.data_struct_version = self.data_struct_version
    db_info.match_times = self.match_times
    return self.module_name, db_info
end

function RoleMatch:_on_msg_req_join_match(pid, msg)
    log_debug("RoleMatch:_on_msg_req_join_match")
    self.role:send_to_client(ProtoId.rsp_join_match, {
        match_type = msg.match_type,
        error_num = Error_None,
    })
end