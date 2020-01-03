
MainLogicStateMgr = MainLogicStateMgr or class("MainLogicStateMgr", StateMgr)

function MainLogicStateMgr:ctor(main_logic)
    MainLogicStateMgr.super.ctor(self)
    self.main_logic = main_logic
end

function MainLogicStateMgr:_prepare_all_states()
    MainLogicStateMgr.super._prepare_all_states(self, self.main_logic)
    self:_add_state_help(MainLogicStateWaitTask:new(self, self.main_logic))
    self:_add_state_help(MainLogicStateInitGame:new(self, self.main_logic))
    self:_add_state_help(MainLogicStateInGame:new(self, self.main_logic))
    self:_add_state_help(MainLogicStateExitGame:new(self, self.main_logic))
end

