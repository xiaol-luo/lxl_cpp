local Login_Phase = {
    idle = "idle",
    connect_login = "connect_login",
    connect_gate = "connect_gate",
    all_done = "all_done",
    raise_error = "raise_error",
}

InGameStateLogin = InGameStateLogin or class("InGameStateLogin", InGameStateBase)

function InGameStateLogin:ctor(state_mgr, in_game_state)
    InGameStateLogin.super.ctor(self, state_mgr, In_Game_State_Name.login, in_game_state)
    self.curr_phase = Login_Phase.idle
end


function InGameStateLogin:on_enter(params)
    InGameStateLogin.super.on_enter(self, params)
    self.curr_phase = Login_Phase.idle
    self.main_logic.login_cnn_logic:reset("", 0)
    self.in_game_state.main_logic.ui_panel_mgr:show_panel(UI_Panel_Name.login_panel, {

    })
end

function InGameStateLogin:on_update()
    InGameStateLogin.super.on_update(self)
    -- todo:
end

function InGameStateLogin:on_exit()
    InGameStateLogin.super.on_exit(self)
end
