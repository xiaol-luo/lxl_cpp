
---@class GameRoleRoom:GameRoleModule
GameRoleRoom = GameRoleRoom or class("RoleBaseInfo", GameRoleModule)

function GameRoleRoom:ctor(role)
    GameRoleRoom.super.ctor(self, role, Game_Role_Module_Name.room)
    self._data_struct_version = nil
    self._example_name = nil
end

function GameRoleRoom:_on_init_from_db(db_ret)
    local db_info = db_ret[self._module_name] or {}
    local data_struct_version = db_info.data_struct_version or Game_Role_Data_Struct_Version.example
    if nil == db_info.data_struct_version or Game_Role_Data_Struct_Version.example ~= data_struct_version then
        self._data_struct_version = Game_Role_Data_Struct_Version.example
        -- maybe do some adjust
        self:set_dirty()
    else
        self._data_struct_version = db_info.data_struct_version
    end

    if GameRole.is_first_launch(db_ret) then
        self._example_name = string.format("_example_name_%s", self._role:get_role_id())
    else
        self._example_name = db_info.example_name
    end
    return true
end

function GameRoleRoom:_on_pack_for_db(out_ret)
    local db_info = {}
    out_ret[self._module_name] = db_info
    db_info.data_struct_version = self._data_struct_version
    db_info.example_name = self._example_name
end

function GameRoleRoom:set_example_name(example_name)
    if not is_string(example_name) or #example_name <= 0 then
        return
    end
    self._example_name = example_name
    self:set_dirty()
end

function GameRoleRoom:get_example_name()
    return self._example_name
end