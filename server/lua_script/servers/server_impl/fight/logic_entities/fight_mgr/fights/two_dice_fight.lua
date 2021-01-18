
---@class TwoDiceFight:FightBase
TwoDiceFight = TwoDiceFight or class("TwoDiceFight", FightBase)

function TwoDiceFight:ctor(fight_mgr, setup_data)
    TwoDiceFight.super.ctor(self, fight_mgr, setup_data)
    self._fight_state = Two_Dice_Fight_State.idle

    self._fight_start_sec = nil
    self._fight_over = false

    self._curr_round = {
        round = 0,
        round_start_sec = nil,
        roll_points = { --[[ [role_id] = roll_point, --]]},
    }

    self._history_rounds = {}
    self._can_join_role_map = {}
    self._ready_fight_role_map = {}

    self._last_update_sec = 0
end

function TwoDiceFight:_on_init(...)
    TwoDiceFight.super._on_init(self)

    log_print("TwoDiceFight:ctor", self.setup_data)
    for _, camp in pairs(self.setup_data.room_camps) do
        for role_id, role_data in pairs(camp) do
            self._can_join_role_map[role_id] = role_data
        end
    end
    log_print("TwoDiceFight:ctor self._join_role_ids", self._can_join_role_map)
end

function TwoDiceFight:_on_start()
    TwoDiceFight.super._on_start(self)
    self._fight_start_sec = logic_sec()
    self._fight_state = Two_Dice_Fight_State.wait_role_ready_to_fight
    self._timer_proxy:firm(Functional.make_closure(self.update, self), 120, Forever_Execute_Timer)
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

    local now_sec = logic_sec()
    if now_sec < self._last_update_sec + 1 then
        return
    end
    self._last_update_sec = now_sec

    if self._fight_start_sec and not self:is_over() then
        if logic_sec() > self._fight_start_sec + 120 then
            self._fight_state = Two_Dice_Fight_State.all_over
            self:sync_brief_state()
        end
    end

    self:_check_next_round()
end

function TwoDiceFight:is_over()
    return self._fight_state == Two_Dice_Fight_State.all_over
end

---@param fight_role FightRole
function TwoDiceFight:_on_opera(fight_role, msg)
    local fight_opera = msg.opera
    local opera_params = msg.opera_params
    log_print("TwoDiceFight:_on_opera", fight_opera, fight_role.role_id)

    local ret = Error_Unknown
    if Two_Dice_Opera.notify_ready_to_fight == fight_opera then
        ret = self:_on_opera_notify_ready_to_fight(fight_opera, opera_params)
    end

    if Two_Dice_Opera.roll == fight_opera then
        ret = self:_on_opera_roll(fight_opera, opera_params)
    end

    if Two_Dice_Opera.pull_state == fight_opera then
        ret = self:_on_opera_pull_state(fight_opera, opera_params)
    end
    return ret
end

function TwoDiceFight:_collect_fight_state_data()
    local msg = {}
    msg.common_state = {
        fight_key = self.fight_key,
        is_over = self:is_over()
    }
    msg.join_role_ids = table.keys(self._can_join_role_map)
    msg.history_round = {}
    for _, v in ipairs(self._history_rounds) do
        table.insert(msg.history_round, self:_round_to_msg(v))
    end
    self._curr_round = self:_round_to_msg(self._curr_round)
    msg.fight_start_sec = self._fight_start_sec
    msg.fight_state = self._fight_state
    return Fight_Pid.two_dice_sync_fight_state, msg
end

---@param fight_role FightRole
function TwoDiceFight._on_opera_notify_ready_to_fight(fight_role, opera_param)
    local role_id = fight_role.role_id
    if not self._can_join_role_map[role_id] then
        return Error_Unknown
    end
    self._ready_fight_role_map[role_id] = true

    if Two_Dice_Fight_State.wait_role_ready_to_fight == self._fight_state then
        local all_ready = true
        for role_id, _ in pairs(self._can_join_role_map) do
            if not self._ready_fight_role_map[role_id] then
                all_ready = false
                break
            end
        end
        if all_ready then
            self._fight_state = Two_Dice_Fight_State.fighting
        end
    end
    return Error_None
end

---@param fight_role FightRole
function TwoDiceFight._on_opera_roll(fight_role, opera_param)
    local ret = Error_None
    local role_id = fight_role.role_id
    if not self._can_join_role_map[role_id] then
        ret = Error_Unknown
    else
        if not self._curr_round.roll_points[role_id] then
            self._curr_round.roll_points[role_id] = math.random(1, 6)
        end
    end
    self:_sync_curr_round()
    self:_check_next_round()
    return ret
end

---@param fight_role FightRole
function TwoDiceFight._on_opera_pull_state(fight_role, opera_param)
    self:_sync_brief_state(fight_role.role_id)
    return Error_None
end

function TwoDiceFight:_on_offline_role(role_id, netid)
    self._ready_fight_role_map[role_id] = nil
end

function TwoDiceFight:_check_next_round(is_force_next)
    if Two_Dice_Fight_State.fighting ~= self._fight_state then
        return
    end

    local to_next_round = false
    if is_force_next then
        to_next_round = true
    else
        if self._curr_round.round > 0 then
            if next(self._ready_fight_role_map) then
                local all_roll = true
                for role_id, _ in pairs(self._ready_fight_role_map) do
                    if not self._curr_round.roll_points[role_id] then
                        all_roll = false
                    end
                end
                if all_roll then
                   to_next_round = true
                end
            end
        end
    end

    if to_next_round then
        if self._curr_round.round > 0 then
            table.insert(self._history_rounds, self._curr_round)
        end
        if self._curr_round.round >= Two_Dice_Max_Round then
            self._fight_state = Two_Dice_Fight_State.all_over
            self:_sync_brief_state()
        else
            local old_round = self._curr_round
            self._curr_round = {
                round = old_round.round + 1,
                round_start_sec = nil,
                roll_points = { --[[ [role_id] = roll_point, --]]},
            }
            self:_sync_curr_round()
        end
    end
end

function TwoDiceFight:_sync_curr_round(role_id)
    local msg = self:_round_to_msg(self._curr_round)
    if role_id then
        self:_send_to_role(role_id, Fight_Pid.two_dice_sync_curr_round, msg)
    else
        self:_broadcast_to_roles(Fight_Pid.two_dice_sync_curr_round, msg)
    end
end

function TwoDiceFight:_round_to_msg(round)
    local msg = {}
    msg.round = round.round
    self.roll_results = {}
    for role_id, roll_point in pairs(round.roll_points) do
        table.insert(self.roll_results, {
            role_id = role_id,
            roll_point = roll_point,
        })
    end
    return msg
end

function TwoDiceFight:_sync_brief_state(role_id)
    local msg = {}
    msg.fight_start_sec = self._fight_start_sec
    msg.fight_state = self._fight_state
    msg.curr_round = self._curr_round.round
    if role_id then
        self:_send_to_role(role_id, Fight_Pid.two_dice_sync_brief_state, msg)
    else
        self:_broadcast_to_roles(Fight_Pid.two_dice_sync_brief_state, msg)
    end
end

