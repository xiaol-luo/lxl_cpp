

RoleBaseInfo = RoleBaseInfo or class("RoleBaseInfo", RoleModuleBase)
RoleBaseInfo.Module_Name = "base_info"

function RoleBaseInfo:ctor(role)
    RoleBaseInfo.super.ctor(self, role, RoleBaseInfo.Module_Name)
    self.name = nil
end

function RoleBaseInfo:init_from_db(db_ret)
    local db_info = db_ret.base_info or {}
    local data_struct_version = db_info.data_struct_version or Data_Struct_Version_Role_Base_Info
    if GameRole.is_first_launch(db_ret) then
        self.name = string.format("role_name_%s", self.role.role_id)
    else
        self.name = db_info.name
    end
    self.data_struct_version = data_struct_version
end

function RoleBaseInfo:pack_for_db(out_ret)
    log_debug("RoleBaseInfo:pack_for_db")
    local db_info = {}
    out_ret.base_info = db_info
    db_info.data_struct_version = self.data_struct_version
    db_info.name = self.name
    return db_info
end