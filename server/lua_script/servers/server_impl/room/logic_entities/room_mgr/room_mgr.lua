
---@class RoomMgr:GameLogicEntity
RoomMgr = RoomMgr or class("RoomMgr", GameLogicEntity)

function RoomMgr:ctor(logics, logic_name)
    RoomMgr.super.ctor(self, logics, logic_name)
    ---@type RoomServiceMgr
    self.server = self.server
    ---@type RoomLogicService
    self.logics = self.logics
    ---@type table<string, RoomLogicBase>
    self._theme_to_logic = {}
    ---@type table<string, RoomBase>
    self._key_to_room = {}
end

function RoomMgr:_on_init()
    RoomMgr.super._on_init(self)

    do
        local room_logic = TwoDiceRoomLogic:new(self, Match_Theme.two_dice, {
            match_theme = Match_Theme.two_dice,
        })
        self._theme_to_logic[Match_Theme.two_dice] = room_logic
    end

    for _, logic in pairs(self._theme_to_logic) do
        logic:init()
    end
end

function RoomMgr:_on_start()
    RoomMgr.super._on_start(self)
    for _, logic in pairs(self._theme_to_logic) do
        logic:start()
    end
end

function RoomMgr:_on_stop()
    RoomMgr.super._on_stop(self)
    for _, logic in pairs(self._theme_to_logic) do
        logic:stop()
    end
end

function RoomMgr:_on_release()
    RoomMgr.super._on_release(self)
    for _, logic in pairs(self._theme_to_logic) do
        logic:release()
    end
end

function RoomMgr:_on_update()
    -- log_print("RoomMgr:_on_update")
    for _, logic in pairs(self._theme_to_logic) do
        logic:update()
    end
end

--- rpc函数

function RoomMgr:_on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.room.setup_room] = Functional.make_closure(self._on_rpc_setup_room, self)
    self._method_name_to_remote_call_handle_fns[Rpc.room.query_room_state] = Functional.make_closure(self._on_rpc_query_room_state, self)
    self._method_name_to_remote_call_handle_fns[Rpc.room.notify_fight_over] = Functional.make_closure(self._on_rpc_notify_fight_over, self)
end

---@param rpc_rsp RpcRsp
function RoomMgr:_on_rpc_setup_room(rpc_rsp, room_key, msg)
    -- log_print("MatchRoomMgr:_on_rpc_setup_room", room_key, msg)

    local error_num = Error_None
    local room = self:get_room(room_key)
    if not room then
        error_num, room = self:setup_room(room_key, msg.match_theme, msg)
    end
    rpc_rsp:response(error_num)
end

function RoomMgr:_on_rpc_query_room_state(rpc_rsp, room_key)
    local room = self:get_room(room_key)
    if not room then
        rpc_rsp:response(Error.query_room_state.not_find_room, nil)
    else
        rpc_rsp:response(Error_None, room:collect_sync_room_state())
    end
end

function RoomMgr:_on_rpc_notify_fight_over(rpc_rsp, room_key, fight_key, fight_result)
    -- log_print("RoomMgr:_on_rpc_notify_fight_over", room_key, fight_key, fight_result)
    local error_num = Error_None
    repeat
        local room = self:get_room(room_key)
        if not room then
            error_num = Error.notify_fight_over.not_find_room
            break
        end
        if fight_key ~= room.fight_key then
            error_num = Error.notify_fight_over.fight_key_mismatch
            break
        end
        local room_logic = self._theme_to_logic[room.match_theme]
        if not room_logic then
            error_num = Error_Unknown
            break
        end
        error_num = room_logic:notify_fight_over(room.room_key, fight_result)
        self:remove_room(room_key)
    until true

    rpc_rsp:response(error_num)
end

function RoomMgr:setup_room(room_key, match_theme, setup_data)
    local room = self:get_room(room_key)
    if room then
        return Error.setup_room.room_key_clash, nil
    end
    local room_logic = self._theme_to_logic[match_theme]
    if not room_logic then
        return Error.setup_room.no_fit_theme, nil
    end
    local error_num = Error_None
    error_num, room = room_logic:setup_room(room_key, setup_data)
    if Error_None == error_num then
        self._key_to_room[room_key] = room
    end
    return error_num, room
end

function RoomMgr:get_room(room_key)
    local ret = self._key_to_room[room_key]
    return ret
end

function RoomMgr:remove_room(room_key)
    local room = self:get_room(room_key)
    if room then
        self._key_to_room[room_key] = nil
        local room_logic = self._theme_to_logic[room.match_theme]
        if room_logic then
            room_logic:release_room(room_key)
        end
    end
    return room
end



