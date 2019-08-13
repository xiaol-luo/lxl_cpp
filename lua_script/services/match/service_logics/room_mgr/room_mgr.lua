
RoomMgr = RoomMgr or class("RoomMgr", ServiceLogic)

function RoomMgr:ctor(logic_mgr, logic_name)
    RoomMgr.super.ctor(self, logic_mgr, logic_name)
    self._wait_confirm_join_rooms = {}
    self._all_confirm_join_rooms = {}
end

function RoomMgr:init()
    RoomMgr.super.init(self)

    -- self.service.rpc_mgr:set_req_msg_process_fn(fn_name, Functional.make_closure(fn, self))
end

function RoomMgr:start()
    RoomMgr.super.start(self)
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), 1 * 1000, -1)
end

function RoomMgr:stop()
    RoomMgr.super.stop(self)
end

function RoomMgr:_on_tick()

end

function RoomMgr:add_wait_confirm_join_room(match_type, match_cell_list)
    local room = Room:new(gen_next_seq(), match_type, match_cell_list)
    self._wait_confirm_join_rooms[room.room_id] = room
    room.confirm_join_start_sec = logic_sec()
    room:foreach_role(function(role_id)
        local role = self.service.role_mgr:get_role(role_id)
        if role then
            role.room_id = room.room_id
            role.game_client:call(Functional.make_closure(self._on_rpc_cb_notify_confirm_join_matchs, self, role.role_id, role.game_session_id),
                    GameRpcFn.notify_confirm_join_match, role.role_id, role.game_session_id, role.room_id)
        end
    end)
end

function RoomMgr:get_wait_confirm_join_room(room_id)
    return self._wait_confirm_join_rooms[room_id]
end

function RoomMgr:_on_rpc_cb_notify_confirm_join_match(call_role_id, call_game_session_id, rpc_error_num, error_num, session_id, is_accept)
    if call_game_session_id ~= session_id then
        return
    end
    local role = self.service.role_mgr:get_role(call_role_id)
    if not role or not role.match_room_id then
        return
    end
    if role.game_session_id ~= session_id then
        return
    end
    local room = self._wait_confirm_join_rooms[role.match_room_id]
    if not room then
        -- todo: log error
        return
    end
    room:set_confirm_join_result(role.role_id, is_accept)
    self:_check_process_finish_confirm_join_room(room)
end

function RoomMgr:_check_process_finish_confirm_join_room(room)
    if not room:is_confirm_join_finished() then
        return
    end
    local reject_role_ids = room:get_reject_confirm_join_role_ids()
    local match_succ = (nil == next(reject_role_ids))
    if match_succ then
        self._wait_confirm_join_rooms[room.room_id] = nil
        self._all_confirm_join_rooms[room.room_id] = room
        -- todo 去申请战斗资源等等
        -- for test
        room:foreach_role(function(role_id)
            local role = self.service.role_mgr:get_role(role_id)
            if role then
                role.game_client:call(nil, GameRpcFn.notify_match_succ, role.role_id, role.game_session_id, room.room_id)
            end
        end)
    else
        self._wait_confirm_join_rooms[room.room_id] = nil
        room:foreach_role(function(role_id)
            local role = self.service.role_mgr:get_role(role_id)
            if role then
                self.service.role_mgr:remove_role(role_id)
                role.game_client:call(nil, GameRpcFn.notify_terminate_match, role.role_id, role.game_session_id, Reason.Terminate_Match.room_mate_reject_join)
                role:clear_match_cell()
            end
        end)
    end
end


