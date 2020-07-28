
declare_event_set("Event_Set__State_InGame", {
    "try_enter_login_state",
    "try_enter_logout_state",
})

MainLogicStateInGame = MainLogicStateInGame or class("MainLogicStateInGame", MainLogicCompositeStateBase)

function MainLogicStateInGame:ctor(state_mgr, main_logic)
    MainLogicStateInGame.super.ctor(self, state_mgr, Main_Logic_State_Name.in_game, main_logic)
    self.event_subscriber = self.main_logic.event_mgr:create_subscriber()
end


function MainLogicStateInGame:_prepare_child_states()
    self.child_state_mgr = InGameStateMgr:new(self)
    self.enter_state_name = In_Game_State_Name.enter
    self.exit_state_name = In_Game_State_Name.exit
end


function MainLogicStateInGame:on_enter(params)
    MainLogicStateInGame.super.on_enter(self, params)
    self.event_subscriber:subscribe(Event_Set__State_InGame.try_enter_login_state, Functional.make_closure(self._on_event_try_enter_login_state, self))
    self.event_subscriber:subscribe(Event_Set__State_InGame.try_enter_logout_state, Functional.make_closure(self._on_event_try_enter_logout_state, self))
end

function MainLogicStateInGame:on_exit()
    MainLogicStateInGame.super.on_exit(self)
    self.event_subscriber:release_all()
end

function MainLogicStateInGame:_on_event_try_enter_login_state(params)
    log_debug("MainLogicStateInGame:_on_event_try_enter_login_state")
    self.child_state_mgr:change_state(In_Game_State_Name.login)
end

function MainLogicStateInGame:_on_event_try_enter_logout_state(params)
    self.child_state_mgr:change_state(In_Game_State_Name.logout)
end

