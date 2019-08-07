

RoleMatch = RoleMatch or class("RoleMatch", RoleModuleBase)
RoleMatch.Module_Name = "match"

function RoleMatch:ctor(role)
    RoleMatch.super.ctor(self, role, RoleMatch.Module_Name)
    self.match_times = 0
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

