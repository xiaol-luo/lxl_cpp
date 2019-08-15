
MatchLogic = MatchLogic or class("MatchLogic")
MatchLogic.Tick_Span_Ms = 1000

function MatchLogic:ctor(match_mgr, match_type)
    self.match_mgr = match_mgr
    self.match_type = match_type
    self.id_to_cell = {}
end

function MatchLogic:_create_match_cell()
    assert(false, "should not reach here")
end

function MatchLogic:solo_join(role_id, extra_data)
    assert(false, "should not reach here")
end

function MatchLogic:join(leader_role_id, role_ids, extra_data)
    assert(false, "should not reach here")
end

function MatchLogic:quit(quit_role)
    assert(false, "should not reach here")
end

function MatchLogic:update_logic()
    assert(false, "should not reach here")
end

function MatchLogic:get_cell(cell_id)
    return self.id_to_cell[cell_id]
end

