
MainLogicStateInGame = MainLogicStateInGame or class("MainLogicStateInGame", MainLogicStateBase)

function MainLogicStateInGame:ctor(state_mgr)
    MainLogicStateInGame.super.ctor(self, state_mgr, Main_Logic_State_Name.in_game)
end

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