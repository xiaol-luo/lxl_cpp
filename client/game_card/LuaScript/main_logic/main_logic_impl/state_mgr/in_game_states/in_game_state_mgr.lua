
InGameStateMgr = InGameStateMgr or class("InGameStateMgr", StateMgr)

function InGameStateMgr:ctor(in_game_state)
    InGameStateMgr.super.ctor(self)
    self.in_game_state = in_game_state
end

function InGameStateMgr:_prepare_all_states()
    log_assert(self.in_game_state, "InGameStateMgr:_prepare_all_states %s", tostring(self.in_game_state))
    InGameStateMgr.super._prepare_all_states(self)
    self:_add_state_help(InGameStateEnter:new(self, self.in_game_state))
    self:_add_state_help(InGameStateExit:new(self, self.in_game_state))
    self:_add_state_help(InGameStateLogin:new(self, self.in_game_state))
    self:_add_state_help(InGameStateLogout:new(self, self.in_game_state))
    self:_add_state_help(InGameStateRun:new(self, self.in_game_state))
end

