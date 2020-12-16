
---@class RoomLogicBase
RoomLogicBase = RoomLogicBase or class("RoomLogicBase")

function RoomLogicBase:ctor(room_mgr, match_theme, logic_setting)
    ---@type RoomMgr
    self._room_mgr = room_mgr
    ---@type table
    self._logic_setting = logic_setting
    self._match_theme = match_theme
    ---@type table<string, RoomBase>
    self._key_to_room ={}
    ---@type EventProxy
    self._event_proxy = EventProxy:new()
    ---@type RpcServiceProxy
    self._rpc_svc_proxy = self._room_mgr.server.rpc:create_proxy()
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
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
    self._event_proxy:release_all()
    self._rpc_svc_proxy:clear_remote_call()
    self._timer_proxy:release_all()
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
        return Error.setup_room.room_key_clash, nil
    end

    room = self:create_room(room_key, setup_data)
    local error_num = self:_check_can_setup_room(room)
    if Error_None ~= error_num  then
        return error_num, nil
    end
    self._key_to_room[room_key] = room
    self:_on_setup_room(room)
    return Error_None, room
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

function RoomLogicBase:notify_fight_over(room_key, fight_result)
    local room = self:get_room(room_key)
    if not room then
        return Error.notify_fight_over.not_find_room
    end
    local ret = self:_on_notify_fight_over(room, fight_result)
    return ret
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
    return Error_Unknown
end

function RoomLogicBase:_on_setup_room(room)
    -- override by subclass
end

function RoomLogicBase:_on_release_room(room)
    -- override by subclass
end

function RoomLogicBase:_on_notify_fight_over(room, fight_result)
    -- override by subclass
    return Error_None
end

---@param room RoomBase
function RoomLogicBase:sync_room_state(room, role_id)
    if role_id then
        self._rpc_svc_proxy:call_game_server(nil, role_id,
                Rpc.game.sync_room_state,
                role_id, room.room_key, room:collect_sync_room_state())
    else
        local room_msg = room:collect_sync_room_state()
        for k, _ in pairs(room.id_to_role) do
            self._rpc_svc_proxy:call_game_server(nil, k,
                    Rpc.game.sync_room_state,
                    k, room.room_key, room_msg)
        end
    end
end



