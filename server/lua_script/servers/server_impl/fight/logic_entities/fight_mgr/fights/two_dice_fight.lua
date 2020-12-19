
---@class TwoDiceFight:FightBase
TwoDiceFight = TwoDiceFight or class("TwoDiceFight", FightBase)

function TwoDiceFight:ctor(fight_mgr, setup_data)
    TwoDiceFight.super.ctor(self, fight_mgr, setup_data)

    self._fight_start_sec = nil
    self._fight_over = false
end

function TwoDiceFight:_on_init(...)
    TwoDiceFight.super._on_init(self)
end

function TwoDiceFight:_on_start()
    TwoDiceFight.super._on_start(self)
    self._fight_start_sec = logic_sec()
    self._timer_proxy:firm(Functional.make_closure(self.update, self), 100, Forever_Execute_Timer)
end

function TwoDiceFight:_on_stop()
    TwoDiceFight.super._on_stop(self)
end

function TwoDiceFight:_on_release()
    TwoDiceFight.super._on_release(self)
    -- log_print("TwoDiceFight:_on_release")
    self._rpc_svc_proxy:call(nil, self.room_server_key, Rpc.room.notify_fight_over, self.room_key, self.fight_key, {})
end

function TwoDiceFight:_on_update()
    TwoDiceFight.super._on_update(self)

    if self._fight_start_sec and not self._fight_over then
        if logic_sec() > self._fight_start_sec + 15 then
            self._fight_over = true
        end
    end
end

function TwoDiceFight:_on_opera(fight_role, msg)
    -- override by subclass
    return Error_None
end

---@param fight_client FightClient
function TwoDiceFight:sync_fight_state(fight_client)
    -- override by subclass
end

function TwoDiceFight:is_over()
    return self._fight_over
end

