
RoomMgr = RoomMgr or class("RoomMgr", ServiceLogic)
RoomMgr.Check_Wait_Confirm_Join_Room_Span_Sec = 1

function RoomMgr:ctor(logic_mgr, logic_name)
    RoomMgr.super.ctor(self, logic_mgr, logic_name)
    self._wait_confirm_join_rooms = {}
    self._all_confirm_join_rooms = {}
    self._last_check_wait_confirm_join_room_sec = 0
end

function RoomMgr:init()
    RoomMgr.super.init(self)
end

function RoomMgr:start()
    RoomMgr.super.start(self)
end

function RoomMgr:stop()
    RoomMgr.super.stop(self)
end

function RoomMgr:on_update()
    local now_sec = logic_sec()
    if now_sec - self._last_check_wait_confirm_join_room_sec >= self._last_check_wait_confirm_join_room_sec then
        self._last_check_wait_confirm_join_room_sec = now_sec
        for _, room in ipairs(table.values(self._wait_confirm_join_rooms)) do
            self:_check_process_finish_confirm_join_room(room)
        end
    end
end

function RoomMgr:add_wait_confirm_join_room(match_type, match_cell_list)
    local room = Room:new(gen_next_seq(), match_type, match_cell_list)
    self._wait_confirm_join_rooms[room.room_id] = room
    room.confirm_join_start_sec = logic_sec()
    room:foreach_role(function(role_id)
        local role = self.service.role_mgr:get_role(role_id)
        if role then
            role.room_id = room.room_id
            role.game_client:call(Functional.make_closure(self._on_rpc_cb_notify_confirm_join_match, self, role.role_id, role.game_session_id),
                    GameRpcFn.notify_confirm_join_match, role.role_id, role.game_session_id, role.room_id)
        end
    end)
end

function RoomMgr:get_wait_confirm_join_room(room_id)
    return self._wait_confirm_join_rooms[room_id]
end

function RoomMgr:_on_rpc_cb_notify_confirm_join_match(call_role_id, call_game_session_id, rpc_error_num, is_accept)
    local role = self.service.role_mgr:get_role(call_role_id)
    if not role or not role.match_room_id then
        return
    end
    if call_game_session_id ~= role.game_session_id then
        return
    end
    local room = self._wait_confirm_join_rooms[role.match_room_id]
    if not room then
        -- todo: log error
        return
    end
    local set_is_accept = true
    if Error_None ~= rpc_error_num then
        set_is_accept = false
    end
    if not is_accept then
        set_is_accept = false
    end
    room:set_confirm_join_result(role.role_id, set_is_accept)
    self:_check_process_finish_confirm_join_room(room)
end

function RoomMgr:_check_process_finish_confirm_join_room(room)
    if not room:is_confirm_join_finished() then
        return
    end
    local reject_role_ids = room:get_reject_confirm_join_role_ids()
    local match_succ = (nil == next(reject_role_ids))
    local terminate_match_reason = nil
    if match_succ then
        self._wait_confirm_join_rooms[room.room_id] = nil
        local service_info = self.service.zone_net:rand_service(Service_Const.room)
        if not service_info then
            terminate_match_reason = Reason.Terminate_Match.no_available_room_service
        else
            self._all_confirm_join_rooms[room.room_id] = room
            room.room_client = self.service:create_rpc_client(service_info.key)
            local rpc_match_cells = {}
            for _, match_cell in pairs(room.match_cell_list) do
                local cell_roles = {}
                for role_id, _ in pairs(match_cell.role_ids) do
                    local role = self.service.role_mgr:get_role(role_id)
                    assert(role)
                    cell_roles[role.role_id] = {
                        role_id = role.role_id,
                        game_service_key = role.game_client.remote_host,
                        game_session_id = role.game_session_id
                    }
                end
                table.insert(rpc_match_cells, {
                    leader_role_id = match_cell.leader_role_id,
                    extra_data = match_cell.extra_data,
                    roles = cell_roles,
                })
            end
            room.room_client:call(Functional.make_closure(self._on_rpc_cb_apply_room, self, room.room_id),
                    RoomRpcFn.apply_room, room.match_type, rpc_match_cells)
        end
    else
        self._wait_confirm_join_rooms[room.room_id] = nil
        terminate_match_reason = Reason.Terminate_Match.room_mate_reject_join
    end
    if terminate_match_reason then
        room:foreach_role(function(role_id)
            local role = self.service.role_mgr:get_role(role_id)
            if role and role.game_client then
                role.game_client:call(nil, GameRpcFn.notify_terminate_match, role.role_id, role.game_session_id, terminate_match_reason)
                self.service.role_mgr:remove_role(role_id)
                role:clear_match_cell()
                role.match_room_id = nil
            end
        end)
    end
end

function RoomMgr:_on_rpc_cb_apply_room(room_id, rpc_error_num, error_num, remote_room_id)
    local room = self._all_confirm_join_rooms[room_id]
    if not room then
        return
    end
    self._all_confirm_join_rooms[room_id] = nil
    if Error_None == rpc_error_num and Error_None == error_num then
        room:foreach_role(function(role_id)
            local role = self.service.role_mgr:get_role(role_id)
            if role and role.game_client then
                role.game_client:call(nil, GameRpcFn.notify_match_succ, role.role_id, role.game_session_id, role.room_client.remote_host, remote_room_id)
            end
            if role then
                self.service.role_mgr:remove_role(role_id)
                role:clear_match_cell()
                role.match_room_id = nil
            end
        end)
    else
        room:foreach_role(function(role_id)
            local role = self.service.role_mgr:get_role(role_id)
            if role and role.game_client then
                role.game_client:call(nil, GameRpcFn.notify_terminate_match, role.role_id, role.game_session_id, Reason.Terminate_Match.apply_room_fail)
            end
            if role then
                self.service.role_mgr:remove_role(role_id)
                role:clear_match_cell()
                role.match_room_id = nil
            end
        end)
    end
end


