
---@class AppCompositeStateBase:CompositeStateBase
---@field app LuaApp
---@field state_mgr AppStateMgr
---@field child_state_mgr InGameStateMgr
AppCompositeStateBase = AppCompositeStateBase or class("AppCompositeStateBase", CompositeStateBase)

function AppCompositeStateBase:ctor(state_mgr, state_name, app)
    AppCompositeStateBase.super.ctor(self, state_mgr, state_name)
    self.app = app
end
