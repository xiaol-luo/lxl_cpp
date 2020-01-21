
InGameStateRun = InGameStateRun or class("InGameStateRun", InGameStateBase)

function InGameStateRun:ctor(state_mgr, in_game_state)
    InGameStateRun.super.ctor(self, state_mgr, In_Game_State_Name.run, in_game_state)
end

function InGameStateRun:on_enter(params)
    InGameStateRun.super.on_enter(self, params)
    self.in_game_state.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.main_panel, {})
end

function InGameStateRun:on_update()
    InGameStateRun.super.on_update(self)
    self.main_logic.gate_cnn_logic:update()
end

function InGameStateRun:on_exit()
    InGameStateRun.super.on_exit(self)
end