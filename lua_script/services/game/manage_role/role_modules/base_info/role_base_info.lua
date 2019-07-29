

RoleBaseInfo = RoleBaseInfo or class("RoleBaseInfo", RoleModuleBase)
RoleBaseInfo.Module_Name = "base_info"

function RoleBaseInfo:ctor(role)
    RoleBaseInfo.super.ctor(self, role, RoleBaseInfo.Module_Name)
    self.name = nil
end

function RoleBaseInfo:init_from_db(db_ret)
    local db_info = db_ret.base_info
    local data_struct_version = db_info.data_struct_version or Data_Struct_Version_Role_Base_Info
    if GameRole.is_first_launch(db_ret) then
        self.name = string.format("role_name_%s", self.role:GetRoleId())
    else

    end

end

function RoleBaseInfo:pack_for_db(out_ret)
    local db_info = {}
    out_ret.base_info = db_info

end