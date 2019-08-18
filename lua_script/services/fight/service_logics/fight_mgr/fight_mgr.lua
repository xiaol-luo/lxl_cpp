
FightMgr = FightMgr or class("FightMgr", ServiceLogic)
FightMgr.Fight_Last_Sec = 10
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
    local tid = nil
    tid = self.timer_proxy:delay(function()
        self.timer_proxy:remove(tid)
        tid = nil
        local room_client = self.service:create_rpc_client(rpc_rsp.from_host)
        room_client:call(nil, RoomRpcFn.notify_fight_battle_over, fight.room_id, fight.fight_battle_id)
    end, 10 * 1000)
end

function FightMgr:on_update()
    self:_check_fight_over()
end

function FightMgr:_check_fight_over()
    local now_sec = logic_sec()
    if now_sec - self._last_check_fight_over_sec >= FightMgr.Check_Fight_Over_Span_Sec then
        self._last_check_fight_over_sec = now_sec
        for _, fight_id in pairs(table.keys(self._id_to_fight)) do
            local fight = self._id_to_fight[fight_id]
            if fight then
                if fight.start_fight_sec and now_sec - fight.start_fight_sec >= FightMgr.Fight_Last_Sec then
                    fight.room_client:call(nil, RoomRpcFn.notify_fight_battle_over, fight.room_id, fight.fight_battle_id)
                    self._id_to_fight[fight_id] = nil
                end
            end
        end
    end
end

