
AppStateMgr = AppStateMgr or class("AppStateMgr", StateMgr)

function AppStateMgr:ctor(main_logic)
    AppStateMgr.super.ctor(self)
    self.main_logic = main_logic
end

function AppStateMgr:_prepare_all_states()
    AppStateMgr.super._prepare_all_states(self, self.main_logic)
    self:_add_state_help(AppStateWaitTask:new(self, self.main_logic))
    self:_add_state_help(AppStateInitGame:new(self, self.main_logic))
    self:_add_state_help(AppStateInGame:new(self, self.main_logic))
    self:_add_state_help(AppStateExitGame:new(self, self.main_logic))
end

