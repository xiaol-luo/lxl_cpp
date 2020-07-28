
AppStateBase = AppStateBase or class("AppStateBase", StateBase)

function AppStateBase:ctor(state_mgr, state_name, main_logic)
    AppStateBase.super.ctor(self, state_mgr, state_name)
    self.main_logic = main_logic
end
