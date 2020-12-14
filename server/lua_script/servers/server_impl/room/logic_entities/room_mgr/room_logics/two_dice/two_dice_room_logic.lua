
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

function TwoDiceRoomLogic:_on_setup_room(room)
    
end

function TwoDiceRoomLogic:_on_release_room(room)

end

function TwoDiceRoomLogic:_on_init(...)

end

function TwoDiceRoomLogic:_on_update()

end