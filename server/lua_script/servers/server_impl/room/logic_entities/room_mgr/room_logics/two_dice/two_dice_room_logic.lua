
---@class TwoDiceRoomLogic: RoomLogicBase
TwoDiceRoomLogic = TwoDiceRoomLogic or class("TwoDiceRoomLogic", RoomLogicBase)

function TwoDiceRoomLogic:ctor(room_mgr, match_theme, logic_setting)
    TwoDiceRoomLogic.super.ctor(self, room_mgr, match_theme, logic_setting)
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
            local picked_error_num = pick_error_num(rpc_error_num, error_num)
            if Error_None ~= picked_error_num or not is_accept then
                room.role_replys[role_id] = Reply_State.reject
            else
                room.role_replys[role_id] = Reply_State.accept
            end
            if Room_State.ask_enter_room == room.state then
                local no_pending = true
                local all_accept = true
                for k, v in pairs(room.role_replys) do
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
                        -- todo: 通知状态
                    else
                        room.state = Room_State.all_over
                        -- todo: 通知状态
                    end
                end
            end
        end, role_id, Rpc.game.notify_enter_room, role_id, room.room_key)

    end
end

function TwoDiceRoomLogic:_on_release_room(room)

end

function TwoDiceRoomLogic:_on_init(...)

end

function TwoDiceRoomLogic:_on_update()

end