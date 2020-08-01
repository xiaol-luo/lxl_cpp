
InGameStateEnter = InGameStateEnter or class("InGameStateEnter", InGameStateBase)

function InGameStateEnter:ctor(state_mgr, in_game_state)
    InGameStateEnter.super.ctor(self, state_mgr, In_Game_State_Name.enter, in_game_state)
end

function InGameStateEnter:on_enter(params)
    InGameStateEnter.super.on_enter(params)
    self.state_mgr:change_state(In_Game_State_Name.manage_role)
end



