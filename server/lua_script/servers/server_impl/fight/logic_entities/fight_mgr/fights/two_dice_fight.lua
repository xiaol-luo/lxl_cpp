
---@class TwoDiceFight:FightBase
TwoDiceFight = TwoDiceFight or class("TwoDiceFight", FightBase)

function TwoDiceFight:ctor(fight_mgr, setup_data)
    TwoDiceFight.super.ctor(self, fight_mgr, setup_data)
    self._fight_start_sec = nil
    self._fight_over = false

    self._curr_round = {
        round = 0,
        round_end_sec = 0,
        round_start = false,
        roll_points = {
            -- [role_id] = roll_point,
        },
    }

    self._round_history = {}

    log_print("TwoDiceFight:ctor", setup_data)
    self._join_role_ids = {}
    for _, camp in pairs(setup_data.room_camps) do
        for role_id, role_data in pairs(camp) do
            self._join_role_ids[role_id] = role_data
        end
    end
    log_print("TwoDiceFight:ctor self._join_role_ids", self._join_role_ids)
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
    self._rpc_svc_proxy:call(nil, self.room_server_key, Rpc.room.notify_fight_over, self.room_key, self.fight_key, {})
end

function TwoDiceFight:_on_update()
    TwoDiceFight.super._on_update(self)

    if self._fight_start_sec and not self._fight_over then
        if logic_sec() > self._fight_start_sec + 120 then
            self._fight_over = true
        end
    end
end

function TwoDiceFight:_on_bind_role(new_fight_role, old_fight_role)
    -- override by subclass
end

function TwoDiceFight:is_over()
    return self._fight_over
end

---@param fight_role FightRole
function TwoDiceFight:_on_opera(fight_role, msg)
    local fight_opera = msg.opera
    log_print("TwoDiceFight:_on_opera", fight_opera, fight_role.role_id)

    if Two_Dice_Opera.roll == fight_opera then

    end
    if Two_Dice_Opera.pull_state == fight_opera then

    end
    return Error_None
end

function TwoDiceFight:_collect_fight_state_data()
    -- override by subclass
    local msg = {
        common_state = {
          fight_key = self.fight_key,
          is_over = self:is_over()
        },
    }
    return Fight_Pid.sync_fight_state_two_dice, msg
end


