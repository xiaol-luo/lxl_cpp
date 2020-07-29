
---@class AppStateMgr:StateMgr
---@field app LuaApp
---@field active_state AppStateBase
AppStateMgr = AppStateMgr or class("AppStateMgr", StateMgr)

function AppStateMgr:ctor(app)
    AppStateMgr.super.ctor(self)
    self.app = app
end

function AppStateMgr:_prepare_all_states()
    AppStateMgr.super._prepare_all_states(self, self.app)
    self:_add_state_help(AppStateWaitTask:new(self, self.app))
    self:_add_state_help(AppStateInitGame:new(self, self.app))
    self:_add_state_help(AppStateInGame:new(self, self.app))
    self:_add_state_help(AppStateExitGame:new(self, self.app))
end

