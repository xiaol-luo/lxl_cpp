
FightMgr = FightMgr or class("FightMgr", ServiceLogic)
FightMgr.Fight_Last_Sec = 10
FightMgr.Check_Fight_Over_Span_Sec = 1

function FightMgr:ctor(logic_mgr, logic_name)
    FightMgr.super.ctor(self, logic_mgr, logic_name)
end

function FightMgr:init()
    FightMgr.super.init(self)
end

function FightMgr:start()
    FightMgr.super.start(self)
end

function FightMgr:stop()
    FightMgr.super.stop(self)
end

function FightMgr:on_update()
end

