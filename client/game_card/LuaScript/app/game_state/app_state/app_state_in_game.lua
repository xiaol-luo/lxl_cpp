
declare_event_set("Event_Set__State_InGame", {
    "try_enter_login_state",
    "try_enter_logout_state",
})

---@class AppStateInGame:AppCompositeStateBase
AppStateInGame = AppStateInGame or class("AppStateInGame", AppCompositeStateBase)

function AppStateInGame:ctor(state_mgr, app)
    AppStateInGame.super.ctor(self, state_mgr, App_State_Name.in_game, app)
    -- self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
end


function AppStateInGame:_prepare_child_states()
    self.child_state_mgr = InGameStateMgr:new(self)
    self.enter_state_name = In_Game_State_Name.enter
    self.exit_state_name = In_Game_State_Name.exit
end


function AppStateInGame:on_enter(params)
    AppStateInGame.super.on_enter(self, params)
    -- self.event_binder:bind(self.app, Event_Set__State_InGame.try_enter_login_state, Functional.make_closure(self._on_event_try_enter_login_state, self))
    -- self.event_binder:bind(self.app, Event_Set__State_InGame.try_enter_logout_state, Functional.make_closure(self._on_event_try_enter_logout_state, self))
end

function AppStateInGame:on_exit()
    AppStateInGame.super.on_exit(self)
    -- self.event_subscriber:release_all()
end

--function AppStateInGame:_on_event_try_enter_login_state(params)
--    log_debug("AppStateInGame:_on_event_try_enter_login_state")
--    self.child_state_mgr:change_state(In_Game_State_Name.login)
--end
--
--function AppStateInGame:_on_event_try_enter_logout_state(params)
--    self.child_state_mgr:change_state(In_Game_State_Name.logout)
--end

