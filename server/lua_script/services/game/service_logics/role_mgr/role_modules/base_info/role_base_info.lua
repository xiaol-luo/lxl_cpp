

GameRoleBaseInfo = GameRoleBaseInfo or class("RoleBaseInfo", RoleModuleBase)
GameRoleBaseInfo.Module_Name = "base_info"

function GameRoleBaseInfo:ctor(role)
    GameRoleBaseInfo.super.ctor(self, role, GameRoleBaseInfo.Module_Name)
    self.name = nil
end

function GameRoleBaseInfo:init_from_db(db_ret)
    local db_info = db_ret[self.module_name] or {}
    local data_struct_version = db_info.data_struct_version or Data_Struct_Version_Role_Base_Info
    if nil == db_info.data_struct_version or db_info.data_struct_version ~= Data_Struct_Version_Role_Base_Info then
        self:set_dirty()
    end
    self.data_struct_version = data_struct_version

    if GameRole.is_first_launch(db_ret) then
        self.name = string.format("role_name_%s", self.role.role_id)
    else
        self.name = db_info.name
    end
end

function GameRoleBaseInfo:pack_for_db(out_ret)
    log_debug("RoleBaseInfo:pack_for_db")
    local db_info = {}
    out_ret[self.module_name] = db_info
    db_info.data_struct_version = self.data_struct_version
    db_info.name = self.name
    return self.module_name, db_info
end