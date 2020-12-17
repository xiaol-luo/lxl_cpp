
---@class FightBase
FightBase = FightBase or class("FightBase")

function FightBase:ctor(fight_mgr, setup_data)
    self._fight_mgr = fight_mgr
    self.setup_data = setup_data

    self.fight_key = nil
    self.room_server_key = nil
    self.room_key = nil

    ---@type EventProxy
    self._event_proxy = EventProxy:new()
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()

    self.is_over = false

    ---@type table<number, FightRole>
    self._id_to_role = {}
end

function FightBase:init()
    self.fight_key = gen_uuid()
    self.room_key = self.setup_data.room_key
    self.room_server_key = self.setup_data.room_server_key
    self:_on_init()
end

function FightBase:start()
    self:_on_start()
end

function FightBase:stop()
    self:_on_stop()
end

function FightBase:release()
    self._event_proxy:release_all()
    self._timer_proxy:release_all()
    self:_on_release()
    for k, v in pairs(self._id_to_role) do
        ---@type FightClient
        local client = v.wt.client
        if client then
            client:disconnect()
        end
    end
end

function FightBase:update()
    self:_on_update()
end

function FightBase:_on_init()
    -- override by subclass
end

function FightBase:_on_start()
    -- override by subclass
end

function FightBase:_on_stop()
    -- override by subclass
end

function FightBase:_on_release()
    -- override by subclass
end

function FightBase:_on_update()
    -- override by subclass
end

function FightBase:_on_opera(fight_role, msg)
    -- override by subclass
    return Error_None
end

---@param fight_client FightClient
function FightBase:sync_fight_state(fight_client)
    -- override by subclass
end

---@param fight_role FightRole
function FightBase:bind_role(fight_role)
    -- 简单处理，后边加校验
    local old_fight_role = self._id_to_role[fight_role.role_id]
    if old_fight_role and old_fight_role.netid ~= fight_role.netid then
        ---@type FightClient
        local client = old_fight_role.wt.client
        if client then
            client:disconnect()
        end
    end
    self._id_to_role[fight_role.role_id] = fight_role
    return Error_None
end

---@param fight_role FightRole
function FightBase:handle_role_opera(fight_role, msg)
    local now_fight_role = self._id_to_role[fight_role.role_id]
    if now_fight_role.netid ~= fight_role.netid then
        return Error.fight.netid_mismatch
    end
    local ret = self:_on_opera(fight_role, msg)
    return ret
end


