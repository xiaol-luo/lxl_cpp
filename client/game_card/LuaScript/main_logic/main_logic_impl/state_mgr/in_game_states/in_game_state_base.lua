
InGameStateBase = InGameStateBase or class("InGameStateBase", StateBase)

function InGameStateBase:ctor(state_mgr, state_name, in_game_state)
    InGameStateBase.super.ctor(self, state_mgr, state_name)
    self.main_logic = self.state_mgr.main_logic
    self.in_game_state = in_game_state
end
