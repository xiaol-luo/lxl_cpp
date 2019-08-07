
MatchAgentMgr = MatchAgentMgr or class("MatchAgentMgr", ServiceLogic)

function MatchAgentMgr:ctor(logic_mgr, logic_name)
    MatchAgentMgr.super.ctor(self, logic_mgr, logic_name)
    self.rpc_mgr = self.service.rpc_mgr
end

function MatchAgentMgr:init()
    MatchAgentMgr.super.init(self)
end
