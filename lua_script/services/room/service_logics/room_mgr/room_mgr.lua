
RoomMgr = RoomMgr or class("RoomMgr", ServiceLogic)

RoomMgr.Check_Wait_Role_Ready_Span_Sec = 1
RoomMgr.Wait_All_Role_Bind_Expire_Sec = 15

function RoomMgr:ctor(logic_mgr, logic_name)
    RoomMgr.super.ctor(self, logic_mgr, logic_name)
    self._id_to_room = {}
    self._last_check_wait_role_ready_sec = 0
end

function RoomMgr:init()
    RoomMgr.super.init(self)
    self:_init_process_rpc_handler()
end

function RoomMgr:start()
    RoomMgr.super.start(self)
end

function RoomMgr:stop()
    RoomMgr.super.stop(self)
end

function RoomMgr:on_update()
    self:_check_remove_wait_role_ready_expire_rooms()
end

function RoomMgr:_check_remove_wait_role_ready_expire_rooms()
    local now_sec = logic_sec()
    if now_sec - self._last_check_wait_role_ready_sec >= RoomMgr.Check_Wait_Role_Ready_Span_Sec then
        for _, room_id in pairs(table.keys(self._id_to_room)) do
            local room = self._id_to_room[room_id]
            if room and Room_State.wait_roles_ready == room.state then
                if room.wait_role_ready_start_sec and now_sec - room.wait_role_ready_start_sec >= RoomMgr.Wait_All_Role_Bind_Expire_Sec then
                    self._id_to_room[room.room_id] = nil
                    room.state = Room_State.released
                    room:foreach_role(function(role)
                        if role.game_client then
                            role.game_client:call(GameRpcFn.notify_terminate_room, room.room_id, role.role_id, role.session_id)
                        end
                    end)
                end
            end
        end
    end
end

