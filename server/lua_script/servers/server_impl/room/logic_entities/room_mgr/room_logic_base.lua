
---@class RoomLogicBase
RoomLogicBase = RoomLogicBase or class("RoomLogicBase")

function RoomLogicBase:ctor(room_mgr, logic_setting)
    ---@type RoomMgr
    self._room_mgr = room_mgr
    ---@type table
    self._logic_setting = logic_setting
    ---@type table<string, RoomBase>
    self._key_to_room ={}
end

function RoomLogicBase:init()
    self:_on_init()
end

function RoomLogicBase:start()
    self:_on_start()
end

function RoomLogicBase:stop()
    self:_on_stop()
end

function RoomLogicBase:release()
    self:_on_release()
end

function RoomLogicBase:update()
    self:_on_update()
end

function RoomLogicBase:create_room(room_key, setup_data)
    -- override by subclass
    return nil
end

function RoomLogicBase:setup_room(room_key, setup_data)
    local room = self:get_room(room_key)
    if room then
        return false, nil
    end
    room = self:create_room(room_key, setup_data)
    if not self:_check_can_setup_room(room) then
        return false, nil
    end
    self._key_to_room[room_key] = room
    self:_on_setup_room(room)
    return true, room
end

function RoomLogicBase:release_room(room_key)
    local room_room = self:get_room(room_key)
    if room_room then
        self._key_to_room[room_key] = nil
        self:_on_release_room(room_room)
    end
end

function RoomLogicBase:get_room(room_key)
    return self._key_to_room[room_key]
end

function RoomLogicBase:_on_init(...)
    -- override by subclass
end

function RoomLogicBase:_on_start()
    -- override by subclass
end

function RoomLogicBase:_on_stop()
    -- override by subclass
end

function RoomLogicBase:_on_release()
    -- override by subclass
end

function RoomLogicBase:_on_update()
    -- override by subclass
end

function RoomLogicBase:_check_can_setup_room(room)
    -- override by subclass
    return false
end

function RoomLogicBase:_on_setup_room(room)
    -- override by subclass
end

function RoomLogicBase:_on_release_room(room)
    -- override by subclass
end


