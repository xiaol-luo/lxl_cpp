
---@class RoleFight:GameRoleModule
RoleFight = RoleFight or class("RoleFight", GameRoleModule)

function RoleFight:ctor(role)
    RoleFight.super.ctor(self, role, Game_Role_Module_Name.fight)
    self._data_struct_version = nil
    ---@type Role_Fight_State
    self._state = Role_Fight_State.idle
    self._token = nil
    ---@type Fight_Type
    self._fight_type = nil
    ---@type RoleFightMatchData
    self._match_data = nil
    ---@type RoleFightRoomData
    self._room_data = nil
end

function RoleFight:_on_init_from_db(db_ret)
    local db_info = db_ret[self._module_name] or {}
    local data_struct_version = db_info.data_struct_version or Game_Role_Data_Struct_Version.fight
    if nil == db_info.data_struct_version or Game_Role_Data_Struct_Version.fight ~= data_struct_version then
        self._data_struct_version = Game_Role_Data_Struct_Version.fight
        -- maybe do some adjust
        self:set_dirty()
    else
        self._data_struct_version = db_info.data_struct_version
    end

    return true
end

function RoleFight:_on_pack_for_db(out_ret)
    local db_info = {}
    out_ret[self._module_name] = db_info
    db_info.data_struct_version = self._data_struct_version
end

function RoleFight:on_msg_req_join_match(pid, msg)
    self._role:send_msg(Fight_Pid.rsp_join_match, { error_num = Error_None })
end

function RoleFight:on_msg_req_quit_match(pid, msg)
    self._role:send_msg(Fight_Pid.rsp_quit_match, { error_num = Error_None })
end

