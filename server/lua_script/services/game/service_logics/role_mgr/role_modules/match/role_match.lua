

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
    self:init_process_client_msg()
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

function RoleMatch:clear_match_state()
    self.state = Role_Match_State.free
    self.match_client = nil
    self.match_session_id = nil
    self.match_cell_id = nil
end

function RoleMatch:sync_match_state()
    self.role:send_to_client(ProtoId.sync_match_state, {
        state = self.state
    })
end
