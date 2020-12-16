
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
