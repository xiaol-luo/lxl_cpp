
FightMgr = FightMgr or class("FightMgr", ServiceLogic)
FightMgr.Fight_Last_Sec = 600
FightMgr.Check_Fight_Over_Span_Sec = 1

function FightMgr:ctor(logic_mgr, logic_name)
    FightMgr.super.ctor(self, logic_mgr, logic_name)
    self._id_to_fight = {}
    self._last_check_fight_over_sec = 0
end

function FightMgr:init()
    FightMgr.super.init(self)
    self:_init_process_rpc_handler()
end

function FightMgr:start()
    FightMgr.super.start(self)
end

function FightMgr:stop()
    FightMgr.super.stop(self)
end

function FightMgr:on_update()
    self:_fight_update()
    self:_check_fight_over()
end

function FightMgr:_fight_update()
    for _, fight in pairs(self._id_to_fight) do
        fight:update()
    end
end

function FightMgr:_check_fight_over()
    local now_sec = logic_sec()
    if now_sec - self._last_check_fight_over_sec >= FightMgr.Check_Fight_Over_Span_Sec then
        self._last_check_fight_over_sec = now_sec
        for _, fight_id in pairs(table.keys(self._id_to_fight)) do
            local fight = self._id_to_fight[fight_id]
            if fight then
                if fight:wait_release() then
                    local fight_result = fight:get_fight_result()
                    fight.room_client:call(nil, RoomRpcFn.notify_fight_battle_over, fight.room_id, fight.fight_battle_id, fight_result)
                    self._id_to_fight[fight_id] = nil
                    fight:release()
                end
            end
        end
    end
end

function FightMgr:get_fight(fight_id)
    local fight = self._id_to_fight[fight_id]
    return fight
end

