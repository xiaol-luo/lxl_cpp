
AppCompositeStateBase = AppCompositeStateBase or class("AppCompositeStateBase", CompositeStateBase)

function AppCompositeStateBase:ctor(state_mgr, state_name, main_logic)
    AppCompositeStateBase.super.ctor(self, state_mgr, state_name)
    self.main_logic = main_logic
end
