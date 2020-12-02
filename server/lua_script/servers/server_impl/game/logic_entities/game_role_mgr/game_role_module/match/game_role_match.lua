
---@class GameRoleMatch:GameRoleModule
GameRoleMatch = GameRoleMatch or class("RoleBaseInfo", GameRoleModule)

function GameRoleMatch:ctor(role)
    GameRoleMatch.super.ctor(self, role, Game_Role_Module_Name.match)
    self._data_struct_version = nil
    self._is_matching = false
    self._match_server_key = nil
    self._match_theme = nil
    self._match_key = nil
end

function GameRoleMatch:_on_init_from_db(db_ret)
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
        self._is_matching = false
    else
        self._is_matching = db_info.is_matching
        self._match_server_key = db_info.match_server_key
        self._match_theme = db_info.match_theme
        self._match_key = db_info.match_key
    end
    return true
end

function GameRoleMatch:_on_pack_for_db(out_ret)
    local db_info = {}
    out_ret[self._module_name] = db_info
    db_info.data_struct_version = self._data_struct_version
    db_info.is_matching = self._is_matching
    db_info.match_server_key = self._match_server_key
    db_info.match_theme = self._match_theme
    db_info.match_key = self._match_key
end

function GameRoleMatch:set_match_data(is_matching, match_server_key, match_theme, match_key)
    self._is_matching = is_matching
    self._match_server_key = match_server_key
    self._match_theme = match_theme
    self._match_key = match_key
end

function GameRoleMatch:get_match_data()
    local ret = {}
    ret.data_struct_version = self._data_struct_version
    ret.is_matching = self._is_matching
    ret.match_server_key = self._match_server_key
    ret.match_theme = self._match_theme
    ret.match_key = self._match_key
    return ret
end