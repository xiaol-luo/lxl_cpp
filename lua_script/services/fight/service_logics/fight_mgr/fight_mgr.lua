
FightMgr = FightMgr or class("FightMgr", ServiceLogic)

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
