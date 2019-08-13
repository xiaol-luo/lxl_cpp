
FightAgentMgr = FightAgentMgr or class("FightAgentMgr", ServiceLogic)

function FightAgentMgr:ctor(logic_mgr, logic_name)
    FightAgentMgr.super.ctor(self, logic_mgr, logic_name)
end

function FightAgentMgr:init()
    FightAgentMgr.super.init(self)
end

function FightAgentMgr:start()
    FightAgentMgr.super.start(self)
end

function FightAgentMgr:stop()
    FightAgentMgr.super.stop(self)
end
