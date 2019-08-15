
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
    self.timer_proxy:firm(Functional.make_closure(self._update_logic, self), SERVICE_MICRO_SEC_PER_FRAME, -1)
end

function MatchMgr:stop()
    MatchMgr.super.stop(self)
    self.timer_proxy:release_all()
end

function MatchMgr:solo_join(match_type, role_id, extra_data)
    local match_logic = self._match_logic_map[match_type]
    if not match_logic then
        return Error.Join_Match.invalid_match_type
    end
    return match_logic:solo_join(role_id, extra_data)
end

function MatchMgr:quit(role_id)
    local role = self.service.role_mgr:get_role(role_id)
    if not role then
        return Error.Quit_Match.not_matching
    end
    local match_logic = self._match_logic_map[role.match_type]
    if not match_logic then
        return Error_Unknown
    end
    match_logic:quit(role)
end

function MatchMgr:_update_logic()
    for _, logic in pairs(self._match_logic_map) do
        logic:update_logic()
    end
end

function MatchMgr:get_cell(match_type, cell_id)
    local match_logic = self._match_logic_map[match_type]
    if not match_logic then
        return nil
    end
    return match_logic:get_cell(cell_id)
end