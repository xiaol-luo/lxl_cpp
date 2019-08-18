

RoleRoom = RoleRoom or class("RoleRoom", RoleModuleBase)
RoleRoom.Module_Name = "room"

function RoleRoom:ctor(role)
    RoleRoom.super.ctor(self, role, RoleRoom.Module_Name)
    self.join_match_type = Match_Type.none
    self.state = Role_Room_State.free

    self.room_client = nil
    self.room_session_id = nil
    self.room_id = nil
    self._last_check_bind_sec = 0
    self.fight_service_key = nil
    self.fight_battle_id = nil
    self.is_fight_started = false
end

function RoleRoom:init()
    RoleRoom.super.init(self)
    self:init_process_client_msg()
end

function RoleRoom:init_from_db(db_ret)

end

function RoleRoom:pack_for_db(out_ret)
    local db_info = {}
    return self.module_name, db_info
end

function RoleRoom:bind_room(join_match_type, room_service_key, session_id, room_id)
    self:unbind_room(self.room_session_id)
    self.join_match_type = join_match_type
    self.state = Role_Room_State.try_enter_room
    self.room_session_id = session_id
    self.room_id = room_id
    self.room_client = SERVICE_MAIN:create_rpc_client(room_service_key)
    self._last_check_bind_sec = 0
    self:_check_try_bind_room()
end

function RoleRoom:unbind_room(session_id)
    if self.session_id ~= session_id then
        return
    end
    if Role_Room_State.try_enter_room == self.state or Role_Room_State.in_room == self.state then
        self.room_client:call(nil, RoomRpcFn.unbind_room, self.room_id, self.role.role_id, self.room_session_id)
    end
    self.role:send_to_client(ProtoId.notify_unbind_room, {
        session_id = self.session_id,
        room_id = self.room_id
    })
    self:reset_room()
end

function RoleRoom:reset_room()
    self.state = Role_Room_State.free
    self.room_session_id = nil
    self.room_id = nil
    self.join_match_type = nil
    self.room_client = nil
    self._last_check_bind_sec = 0
    self.fight_service_host = nil
    self.fight_service_ip = nil
    self.fight_id = nil
    self.is_fight_started = nil
end

function RoleRoom:_check_try_bind_room()
    if Role_Room_State.try_enter_room ~= self.state then
        return
    end
    local now_sec = logic_sec()
    if now_sec - self._last_check_bind_sec < Role_Room_Try_Bind_Span_Sec then
        return
    end
    self.room_client:call(Functional.make_closure(self._on_rpc_cb_bind_room, self),
            RoomRpcFn.bind_room, self.room_id, self.role.role_id, self.room_session_id)
end

function RoleRoom:_on_rpc_cb_bind_room(rpc_error_num, error_num, session_id, fight_service_ip, fight_service_port, fight_battle_id, is_fight_started)
    if Error_None ~= rpc_error_num then
        -- self:unbind_room(self.room_session_id)
        if Error_Rpc_Expired == rpc_error_num then
            self:_check_try_bind_room()
        else
            self:unbind_room(self.room_session_id)
        end
        return
    end
    if session_id ~= self.room_session_id then
        return
    end
    if Role_Room_State.try_enter_room ~= self.state then
        return
    end
    if Error_None ~= error_num then
        self:unbind_room(self.room_session_id)
    else
        self.state = Role_Room_State.in_room
        self.fight_service_ip = fight_service_ip
        self.fight_service_port = fight_service_port
        self.fight_battle_id = fight_battle_id
        self.is_fight_started = is_fight_started
        self.role:send_to_client(ProtoId.notify_bind_room, {
            session_id = self.room_session_id,
            room_id = self.room_id
        })
        self:sync_room_state()
    end
end

function RoleRoom:sync_room_state()
    self.role:send_to_client(ProtoId.sync_room_state, {
        session_id = self.room_session_id,
        room_id = self.room_id,
        state = self.state,
        join_match_type = self.join_match_type,
        fight_service_ip = self.fight_service_ip,
        fight_service_port = self.fight_service_port,
        fight_battle_id = self.fight_battle_id,
        is_fight_started = self.is_fight_started,
    })
end


