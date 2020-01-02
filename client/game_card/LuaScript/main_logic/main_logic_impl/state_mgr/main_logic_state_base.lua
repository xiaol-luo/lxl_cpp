
MainLogicStateBase = MainLogicStateBase or class("MainLogicStateBase", StateBase)

function MainLogicStateBase:ctor(state_mgr, state_name)
    MainLogicStateBase.super.ctor(self, state_mgr, state_name)
    self.main_logic = self.state_mgr.main_logic
end