
MatchMgr = MatchMgr or class("MatchMgr", ServiceLogic)

function MatchMgr:ctor(logic_mgr, logic_name)
    MatchMgr.super.ctor(self, logic_mgr, logic_name)
end

function MatchMgr:init()
    MatchMgr.super.init(self)
end

function MatchMgr:start()
    MatchMgr.super.start(self)
end

function MatchMgr:stop()
    MatchMgr.super.stop(self)
end

