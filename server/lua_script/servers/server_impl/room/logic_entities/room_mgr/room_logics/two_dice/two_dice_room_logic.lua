
---@class TwoDiceRoomLogic: RoomLogicBase
TwoDiceRoomLogic = TwoDiceRoomLogic or class("TwoDiceRoomLogic", RoomLogicBase)

function TwoDiceRoomLogic:ctor(room_mgr, match_theme, logic_setting)
    TwoDiceRoomLogic.super.ctor(self, room_mgr, match_theme, logic_setting)

    self._last_check_apply_fight_sec = 0
end


function TwoDiceRoomLogic:create_room(room_key, setup_data)
    local room = TwoDiceRoom:new(room_key, setup_data)
    return room
end

function TwoDiceRoomLogic:_check_can_setup_room(room)
    if not room then
        return Error_Unknown
    end
    return Error_None
end

---@param room TwoDiceRoom
function TwoDiceRoomLogic:_on_setup_room(room)
    room.state = Room_State.ask_enter_room
    for key, val in pairs(room.id_to_role) do
        local role_id = key
        local room_role = val
        room.role_replys[role_id] = Reply_State.pending
        self._rpc_svc_proxy:call_game_server(function(rpc_error_num, error_num, is_accept)

        end, role_id, Rpc.game.notify_enter_room, role_id, room.room_key)

    end
end

function TwoDiceRoomLogic:_on_cb_notify_enter_room(room_key, role_id, rpc_error_num, error_num, is_accept)
    local room = self:get_room(room_key)
    if not room or Room_State.ask_enter_room ~= room.state then
        return
    end

    local picked_error_num = pick_error_num(rpc_error_num, error_num)
    if Error_None ~= picked_error_num or not is_accept then
        room.role_replys[role_id] = Reply_State.reject
    else
        room.role_replys[role_id] = Reply_State.accept
    end
    if Room_State.ask_enter_room == room.state then
        local no_pending = true
        local all_accept = true
        for _, v in pairs(room.role_replys) do
            if Reply_State.pending == v then
                no_pending = false
                all_accept = false
                break
            end
            if Reply_State.accept ~= v then
                all_accept = false
            end
        end
        if no_pending then
            if all_accept then
                room.state = Room_State.wait_apply_fight
                for k, v in pairs(room.role_replys) do
                    self:sync_room_state(room, k)
                end
                -- todo:马上申请房间了， 其实可以考虑让他们在房间内先玩耍一会
                room.state = Room_State.apply_fight
                room.try_apply_fight_timestamp = logic_sec() + 5
            else
                room.state = Room_State.all_over
                self._room_mgr:remove_room(room_key)
                for k, v in pairs(room.role_replys) do
                    self._rpc_svc_proxy:call_game_server(nil, k, Rpc.game.notify_room_over, k, room_key)
                    self:sync_room_state(room, k)
                end
            end
        end
    end
end

function TwoDiceRoomLogic:_on_release_room(room)
    self._key_to_room[room.room_key] = nil
end

function TwoDiceRoomLogic:_on_init(...)

end

function TwoDiceRoomLogic:_on_notify_fight_over(room, fight_result)
    room.state = Room_State.all_over
    self:sync_room_state(room)
end

function TwoDiceRoomLogic:_on_update()
    local now_sec = logic_sec()
    if now_sec > self._last_check_apply_fight_sec then
        self._last_check_apply_fight_sec = now_sec

        for room_key, room in pairs(self._key_to_room) do
            if Room_State.apply_fight == room.state
                    and room.try_apply_fight_timestamp
                    and now_sec >= room.try_apply_fight_timestamp then
                room.try_apply_fight_timestamp = nil
                self:_try_apply_fight(room)
            end
        end
    end
end

---@param room RoomBase
function TwoDiceRoomLogic:_try_apply_fight(room)
    if not room.fight_server_key then
        room.fight_server_key = self._room_mgr.server.peer_net:random_server_key(Server_Role.Fight)
    end
    if not room.fight_server_key then
        room.try_apply_fight_timestamp = logic_sec() + 5 -- 5秒后再试
        return
    end
    self._rpc_svc_proxy:call(function(rpc_error_num, error_num, fight_msg)
        local picked_error_num = pick_error_num(rpc_error_num, error_num)
        repeat
            if Error_None ~= picked_error_num then
                room.fight_server_key = nil
                room.try_apply_fight_timestamp = logic_sec() + 5
            else
                room.fight_key = fight_msg.fight_key
                room.fight = {}
                room.fight.ip = fight_msg.ip
                room.fight.port = fight_msg.port
                room.fight.token = fight_msg.token
                if Room_State.apply_fight == room.state then
                    room.state = Room_State.wait_fight_over
                    self:sync_room_state(room)
                end
            end
        until true
    end, room.fight_server_key, Rpc.fight.setup_fight, room:collect_sync_room_state())
end


