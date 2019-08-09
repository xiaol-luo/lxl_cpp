
MatchLogicLuandou = MatchLogicLuandou or class("MatchLogicLuandou", MatchLogic)

function MatchLogicLuandou:ctor(match_mgr, match_type)
    MatchLogicLuandou.super(match_mgr, match_type)
end

function MatchLogicLuandou:_create_match_cell()
    assert(false, "should not reach here")
end

function MatchLogicLuandou:solo_join(role_id, extra_data)
    assert(false, "should not reach here")
end

function MatchLogicLuandou:join(leader_role_id, role_ids, extra_data)
    assert(false, "should not reach here")
end

function MatchLogicLuandou:quit(role_id, match_cell_id)
    assert(false, "should not reach here")
end

function MatchLogicLuandou:update_logic()
    assert(false, "should not reach here")
end

