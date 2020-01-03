
MainLogicStateInGame = MainLogicStateInGame or class("MainLogicStateInGame", MainLogicCompositeStateBase)

function MainLogicStateInGame:ctor(state_mgr, main_logic)
    MainLogicStateInGame.super.ctor(self, state_mgr, Main_Logic_State_Name.in_game, main_logic)
end


function MainLogicStateInGame:_prepare_child_states()
    self.child_state_mgr = InGameStateMgr:new(self)
    self.enter_state_name = In_Game_State_Name.enter
    self.exit_state_name = In_Game_State_Name.exit
end

--[[

function MainLogicStateInGame:on_enter(params)
    MainLogicStateInGame.super.on_enter(self, params)
    self.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.main_panel, {})
end

function MainLogicStateInGame:on_update()
    MainLogicStateInGame.super.on_update(self)
    -- todo:
end

function MainLogicStateInGame:on_exit()
    MainLogicStateInGame.super.on_exit(self)
end

--]]