

function RoomMgr:_init_process_rpc_handler()
    self.service.rpc_mgr:set_req_msg_process_fn(RoomRpcFn.apply_room, Functional.make_closure(self._on_rpc_apply_room, self))
    self.service.rpc_mgr:set_req_msg_process_fn(RoomRpcFn.bind_room, Functional.make_closure(self._on_rpc_bind_room, self))
    self.service.rpc_mgr:set_req_msg_process_fn(RoomRpcFn.unbind_room, Functional.make_closure(self._on_rpc_unbind_room, self))
    self.service.rpc_mgr:set_req_msg_process_fn(RoomRpcFn.notify_fight_battle_over, Functional.make_closure(self._on_rpc_notify_fight_battle_over, self))
end

function RoomMgr:_on_rpc_apply_room(rpc_rsp, match_type, match_cells)
    local fight_service_info = self.service.zone_net:rand_service(Service_Const.fight)
    if not fight_service_info then
        rpc_rsp:respone(Reason.Terminate_Match.no_valid_fight_service)
        return
    end
    local room = Room:new()
    room.room_id = gen_next_seq()
    room.state = Room_State.wait_fight_service_ready
    room.match_type = match_type
    room.match_cells = match_cells
    for _, cell in pairs(room.match_cells) do
        for _, role in pairs(cell.roles) do
            room.all_role_ids[role.role_id] = true
        end
    end
    room.fight_client = self.service:create_rpc_client(fight_service_info.key)
    room.fight_client:call(function(rpc_error_num, error_num, fight_battle_id, fight_service_ip, fight_service_port)
        if Error_None == rpc_error_num and Error_None == error_num then
            room.fight_battle_id = fight_battle_id
            room.state = Room_State.wait_roles_ready
            room.wait_role_ready_start_sec = logic_sec()
            room.fight_service_ip = fight_service_ip
            room.fight_service_port = fight_service_port
            self._id_to_room[room.room_id] = room
            rpc_rsp:respone(Error_None, room.room_id)
        else
            rpc_rsp:respone(Reason.Terminate_Match.apply_fight_battle_fail)
        end
    end, FightRpcFn.apply_fight, room.room_id, match_type, match_cells)
end

function RoomMgr:_on_rpc_bind_room(rpc_rsp, room_id, role_id, session_id)
    local room = self._id_to_room[room_id]
    if not room then
        rpc_rsp:respone(Error.Bind_Room.no_exist_room, session_id)
        return
    end
    local role = room:get_role(role_id)
    if not role then
        rpc_rsp:respone(Error.Bind_Room.no_exist_role, session_id)
        return
    end
    if role.game_session_id ~= session_id then
        rpc_rsp:respone(Error.Bind_Room.session_id_not_equal, session_id)
        return
    end
    room.bind_roles[role_id] = {
        role_id = role_id,
        game_service_key = rpc_rsp.from_host,
        game_session_id = session_id,
        game_client = self.service:create_rpc_client(rpc_rsp.from_host),
    }
    rpc_rsp:respone(Error_None, session_id, room.fight_service_ip, room.fight_service_port, room.fight_battle_id, room.is_fight_started)

    if not room.is_fight_started then
        if room:is_all_bind() then
            room.state = Room_State.roles_ready
            room.fight_client:call(Functional.make_closure(self._on_rpc_cb_start_fight, self, room), FightRpcFn.start_fight, room.fight_battle_id)
        end
    end
end

function RoomMgr:_on_rpc_cb_start_fight(room, rpc_error_num, error_num)
    if Room_State.roles_ready ~= room.state then
        return
    end
    if Error_None ~= rpc_error_num or Error_None ~= error_num then
        room.state = Room_State.released
        self._id_to_room[room.room_id] = nil
        room:foreach_role(function(role)
            if role.game_client then
                role.game_client:call(nil, GameRpcFn.notify_terminate_room, room.room_id, role.role_id, role.session_id)
            end
        end)
    else
        room.state = Room_State.fighting
        room:foreach_role(function(role)
            if role.game_client then
                role.game_client:call(nil, GameRpcFn.notify_fight_start, room.room_id, role.role_id, role.session_id)
            end
        end)
    end
end

function RoomMgr:_on_rpc_unbind_room(rpc_rsp, room_id, role_id, session_id)
    rpc_rsp:respone(Error_None)
    local room = self._id_to_room[room_id]
    if not room then
        return
    end
    local role = room:get_role(role_id)
    if not role then
        return
    end
    if role.session_id ~= session_id then
        return
    end
    room.bind_roles[role_id] = nil
end

function RoomMgr:_on_rpc_notify_fight_battle_over(rpc_rsp, room_id, fight_battle_id)
    rpc_rsp:respone()
    local room = self._id_to_room[room_id]
    if not room then
        return
    end
    self._id_to_room[room.room_id] = nil
    room.state = Room_State.released
    room:foreach_role(function(role)
        if role.game_client then
            role.game_client:call(nil, GameRpcFn.notify_end_room, room.room_id, role.role_id, role.session_id)
        end
    end)
end