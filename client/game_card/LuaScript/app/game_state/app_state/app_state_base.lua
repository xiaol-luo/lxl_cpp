
---@class AppStateBase:StateBase
---@field app LuaApp
---@field state_mgr AppStateMgr
AppStateBase = AppStateBase or class("AppStateBase", StateBase)

function AppStateBase:ctor(state_mgr, state_name, app)
    AppStateBase.super.ctor(self, state_mgr, state_name)
    self.app = app
end
