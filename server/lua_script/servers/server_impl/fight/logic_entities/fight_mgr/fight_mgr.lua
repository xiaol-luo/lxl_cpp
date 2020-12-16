
---@class FightMgr:GameLogicEntity
FightMgr = FightMgr or class("FightMgr", GameLogicEntity)

function FightMgr:_on_init()
    FightMgr.super._on_init(self)
    ---@type MatchServiceMgr
    self.server = self.server
    ---@type table<string, FightBase>
    self._key_to_fight = {}
    ---@type table<string, FightBase>
    self._room_key_to_fight = {}

    self._over_fights = {}
end

function FightMgr:_on_start()
    FightMgr.super._on_start(self)
end

function FightMgr:_on_stop()
    FightMgr.super._on_stop(self)
    self._rpc_svc_proxy:clear_remote_call()
end

function FightMgr:_on_release()
    FightMgr.super._on_release(self)
end

function FightMgr:_on_update()
    -- log_print("FightMgr:_on_update")
    for k, v in pairs(self._key_to_fight) do
        v:update()
        if v.is_over then
            table.insert(self._over_fights, k)
        end
    end
    if next(self._over_fights) then
        for _, v in ipairs(self._over_fights) do
            self:remove_fight(v)
        end
        self._over_fights = {}
    end
end

--- rpc函数

function RoomMgr:_on_map_remote_call_handle_fns()
    self._method_name_to_remote_call_handle_fns[Rpc.room.setup_room] = Functional.make_closure(self._on_rpc_setup_room, self)
end

---@param rpc_rsp RpcRsp
function FightMgr:_on_rpc_setup_room(rpc_rsp, room_key, room_msg)
    room_msg.room_server_key = rpc_rsp.from_host
    room_msg.room_key = room_key
    local fight = TwoDiceFight:new(self, room_msg)
    fight:init()
    self._key_to_fight[fight.fight_key] = fight
    self._room_key_to_fight[room_key] = fight
    fight:start()
end

function FightMgr:get_fight(fight_key)
    local ret = self._key_to_fight[fight_key]
    return ret
end

function FightMgr:get_fight_by_room_key(room_key)
    local ret = self._room_key_to_fight[room_key]
    return room
end

function FightMgr:remove_fight(fight_key)
    local fight = self:get_fight(fight_key)
    if fight then
        fight:stop()
        fight:release()
        self._key_to_fight[fight_key] = nil
        self._room_key_to_fight[fight.room_key] = nil
    end
end


