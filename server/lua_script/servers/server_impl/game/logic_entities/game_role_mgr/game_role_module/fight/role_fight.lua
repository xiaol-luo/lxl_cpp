
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
    ---@type RpcServiceProxy
    self._rpc_proxy = self._server.rpc:create_svc_proxy()
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
    local server_key = self._server.peer_net:random_server_key(Server_Role.Match)
    if not server_key then
        self._role:send_msg(Fight_Pid.rsp_join_match, { error_num = Error.fight.no_avaliable_match_server })
        return
    end
    local token = gen_uuid()
    self._rpc_proxy:call(function(rpc_error_num, error_num)
        local picked_error_num = pick_error_num(rpc_error_num, error_num)
        self._role:send_msg(Fight_Pid.rsp_join_match, { error_num = picked_error_num })
        if Error_None == picked_error_num then
            self._token = token
            self._match_data.server_key = server_key
            self._state = Role_Fight_State.in_match
        end
    end, server_key, Rpc.match.method.join_match, self._role.role_id, token, msg.fight_type)
end

function RoleFight:on_msg_req_quit_match(pid, msg)
    self._role:send_msg(Fight_Pid.rsp_quit_match, { error_num = Error_None })
end

function RoleFight:sync_fight_state()
    local msg = {}
    msg.state = self._state
    msg.token = self._token
    msg.fight_type = self._fight_type
    msg.match_data = {}
    msg.room_data = {}
    self._role:send_msg(Fight_Pid.sync_fight_state, msg)
end
