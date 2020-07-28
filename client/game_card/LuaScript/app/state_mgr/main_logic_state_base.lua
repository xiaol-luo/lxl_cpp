
MainLogicStateBase = MainLogicStateBase or class("MainLogicStateBase", StateBase)

function MainLogicStateBase:ctor(state_mgr, state_name, main_logic)
    MainLogicStateBase.super.ctor(self, state_mgr, state_name)
    self.main_logic = main_logic
end
