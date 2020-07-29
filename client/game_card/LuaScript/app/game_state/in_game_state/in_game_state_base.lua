
---@class InGameStateBase:StateBase
---@field app LuaApp
---@field in_game_state AppStateInGame
InGameStateBase = InGameStateBase or class("InGameStateBase", StateBase)

function InGameStateBase:ctor(state_mgr, state_name, in_game_state)
    InGameStateBase.super.ctor(self, state_mgr, state_name)
    self.in_game_state = in_game_state
    self.app = self.in_game_state.app
end
