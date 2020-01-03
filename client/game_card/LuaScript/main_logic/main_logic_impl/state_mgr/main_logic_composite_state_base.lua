
MainLogicCompositeStateBase = MainLogicCompositeStateBase or class("MainLogicCompositeStateBase", CompositeStateBase)

function MainLogicCompositeStateBase:ctor(state_mgr, state_name, main_logic)
    MainLogicCompositeStateBase.super.ctor(self, state_mgr, state_name)
    self.main_logic = main_logic
end
