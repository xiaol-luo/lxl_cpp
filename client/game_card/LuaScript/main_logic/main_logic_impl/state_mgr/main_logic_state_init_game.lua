
MainLogicStateInitGame = MainLogicStateInitGame or class("MainLogicStateInitGame", MainLogicStateBase)

function MainLogicStateInitGame:ctor(state_mgr)
    MainLogicStateInitGame.super.ctor(self, state_mgr, Main_Logic_State_Name.init_game)
end

function MainLogicStateInitGame:on_enter(params)
    MainLogicStateInitGame.super.on_enter(self, params)
    self.main_logic.ui_panel_mgr:prepare_assets()
end

function MainLogicStateInitGame:on_update()
    MainLogicStateInitGame.super.on_update(self)
    if self:is_all_done() then
        self.state_mgr:change_state(Main_Logic_State_Name.in_game)
    end
end

function MainLogicStateInitGame:on_exit()
    MainLogicStateInitGame.super.on_exit(self)
end

function MainLogicStateInitGame:is_all_done()
    return true
end