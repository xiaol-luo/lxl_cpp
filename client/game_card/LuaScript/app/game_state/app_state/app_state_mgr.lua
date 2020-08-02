
---@class AppStateMgr:StateMgr
---@field app LuaApp
---@field active_state AppStateBase
---@field in_game_state_mgr InGameStateMgr
AppStateMgr = AppStateMgr or class("AppStateMgr", StateMgr)

function AppStateMgr:ctor(app)
    AppStateMgr.super.ctor(self)
    self.app = app
    self.in_game_state_mgr = nil
end

function AppStateMgr:_prepare_all_states()
    AppStateMgr.super._prepare_all_states(self, self.app)
    self:_add_state_help(AppStateWaitTask:new(self, self.app))
    self:_add_state_help(AppStateInit:new(self, self.app))
    self:_add_state_help(AppStateLogin:new(self, self.app))
    self:_add_state_help(AppStateInGame:new(self, self.app))
    self:_add_state_help(AppStateExit:new(self, self.app))
end

function AppStateMgr:init()
    AppStateMgr.super.init(self)
    self.in_game_state_mgr = self.state_map[App_State_Name.in_game].child_state_mgr
    assert(self.in_game_state_mgr)
end

