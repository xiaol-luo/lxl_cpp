
InGameStateLogin = InGameStateLogin or class("InGameStateLogin", InGameStateBase)

function InGameStateLogin:ctor(state_mgr, in_game_state)
    InGameStateLogin.super.ctor(self, state_mgr, In_Game_State_Name.login)
    self.in_game_state = in_game_state
end


function InGameStateLogin:on_enter(params)
    InGameStateLogin.super.on_enter(self, params)
    self.in_game_state.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.main_panel, {
        hello = "world"
    })
end

function InGameStateLogin:on_update()
    InGameStateLogin.super.on_update(self)
    -- todo:
end

function InGameStateLogin:on_exit()
    InGameStateLogin.super.on_exit(self)
end
