
---@class TwoDiceRoomLogic: RoomLogicBase
TwoDiceRoomLogic = TwoDiceRoomLogic or class("TwoDiceRoomLogic", RoomLogicBase)

function TwoDiceRoomLogic:ctor(room_mgr, logic_setting)
    TwoDiceRoomLogic.super.ctor(self, room_mgr, logic_setting)
end


function TwoDiceRoomLogic:create_room(room_key, setup_data)
    local room = TwoDiceRoom:new()
    room.room_key = setup_data.room_key
    room.match_theme = setup_data.match_theme
end

function TwoDiceRoomLogic:_check_can_setup_room(room)
    return true
end

function TwoDiceRoomLogic:_on_setup_room(room)

end

function TwoDiceRoomLogic:_on_release_room(room)

end


function TwoDiceRoomLogic:_on_init(...)

end

function TwoDiceRoomLogic:_on_update()

end