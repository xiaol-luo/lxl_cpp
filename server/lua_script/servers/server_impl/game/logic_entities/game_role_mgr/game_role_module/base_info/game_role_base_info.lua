
---@class GameRoleBaseInfo:GameRoleModule
GameRoleBaseInfo = GameRoleBaseInfo or class("RoleBaseInfo", GameRoleModule)

function GameRoleBaseInfo:ctor(role)
    GameRoleBaseInfo.super.ctor(self, role, Game_Role_Module_Name.base_info)
    self._role_name = nil
    self._data_struct_version = nil
end

function GameRoleBaseInfo:_on_init_from_db(db_ret)
    local db_info = db_ret[self._module_name] or {}
    local data_struct_version = db_info.data_struct_version or Game_Role_Data_Struct_Version.base_info
    if nil == db_info.data_struct_version or Game_Role_Data_Struct_Version.base_info ~= data_struct_version then
        self._data_struct_version = Game_Role_Data_Struct_Version.base_info
        -- maybe do some adjust
        self:set_dirty()
    else
        self._data_struct_version = db_info.data_struct_version
    end

    if GameRole.is_first_launch(db_ret) then
        self._role_name = string.format("role_name_%s", self._role:get_role_id())
    else
        self._role_name = db_info.role_name
    end
    return true
end

function GameRoleBaseInfo:_on_pack_for_db(out_ret)
    local db_info = {}
    out_ret[self._module_name] = db_info
    db_info.data_struct_version = self._data_struct_version
    db_info.role_name = self._role_name
end

function GameRoleBaseInfo:set_role_name(role_name)
    if not is_string(role_name) or #role_name <= 0 then
        return
    end
    self._role_name = role_name
    self:set_dirty()
end

function GameRoleBaseInfo:get_role_name()
    return self._role_name
end