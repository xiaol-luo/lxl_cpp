
MatchMgr = MatchMgr or class("MatchMgr", ServiceLogic)

function MatchMgr:ctor(logic_mgr, logic_name)
    MatchMgr.super.ctor(self, logic_mgr, logic_name)
    self._match_logic_map = {}
end

function MatchMgr:init()
    MatchMgr.super.init(self)

    local match_logic = nil
    match_logic = MatchLogicBalance:new(self, Match_Type.balance)
    self._match_logic_map[match_logic.match_type] = match_logic


    self:init_process_rpc_handler()
end


function MatchMgr:start()
    MatchMgr.super.start(self)
end

function MatchMgr:stop()
    MatchMgr.super.stop(self)
end

function MatchMgr:solo_join(match_type, role_id, extra_data)
    local match_logic = self._match_logic_map[match_type]
    if not match_logic then
        return Error.Join_Match.invalid_match_type
    end
    return match_logic:solo_join(role_id, extra_data)
end

function MatchMgr:quit(role_id, match_cell_id)
    
end

function MatchMgr:_update_logic()

end