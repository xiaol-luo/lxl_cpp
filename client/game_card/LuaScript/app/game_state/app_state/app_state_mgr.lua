
---@class AppStateMgr:StateMgr
---@field app LuaApp
---@field active_state AppStateBase
---@field in_game_state_mgr InGameStateMgr
AppStateMgr = AppStateMgr or class("AppStateMgr", StateMgr)

function AppStateMgr:ctor(app)
    AppStateMgr.super.ctor(self)
    self.app = app
    self.in_game_state_mgr = nil
    self._event_binder = EventBinder:new()
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
    self._event_binder:bind(self.in_game_state_mgr, State_Event.enter_state,
            Functional.make_closure(self._forward_event, In_Game_State_Event.enter_state))
    self._event_binder:bind(self.in_game_state_mgr, State_Event.exit_state,
            Functional.make_closure(self._forward_event, In_Game_State_Event.exit_state))
end

function AppStateMgr:change_in_game_state(in_game_state_name, params)
    self:change_child_state({App_State_Name.in_game, in_game_state_name}, params)
end

function AppStateMgr:release()
    AppStateMgr.super.release(self)
    self.in_game_state_mgr:release()
    self._event_binder:release_all()
end

function AppStateMgr:_forward_event(new_ev_name, ...)
    self:fire(new_ev_name, ...)
end
