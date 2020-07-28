
UILoginPanel = UILoginPanel or class("UILoginPanel", UIPanelBase)

function UILoginPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self.ip_txt = nil
    self.port_txt = nil
    self.cnn_btn = nil
    self.reset_btn = nil
    self.notify_txt = nil
    self.ml_event_subscriber = nil
    self.user_info = nil
    self.account_id_txt = nil
end

function UILoginPanel:init()
    log_debug("UILoginPanel:init")
    self.super.init(self)

    self.ml_event_subscriber = g_ins.event_mgr:create_subscriber()
    self.ip_txt = UIHelp.attach_ui(UIText, self.root_go, "LoginView/Ip/Text")
    self.port_txt = UIHelp.attach_ui(UIText, self.root_go, "LoginView/Port/Text")
    self.account_id_txt = UIHelp.attach_ui(UIText, self.root_go, "LoginView/AccountId/Text")
    self.cnn_btn = UIHelp.attach_ui(UIButton, self.root_go, "LoginView/ConnectBtn")
    self.cnn_btn:set_onclick(Functional.make_closure(self.on_click_cnn_btn, self))
    self.reset_btn = UIHelp.attach_ui(UIButton, self.root_go, "LoginView/ResetBtn")
    self.reset_btn:set_onclick(Functional.make_closure(self.on_click_reset_btn, self))
    self.notify_txt = UIHelp.attach_ui(UIText, self.root_go, "NotifyTxt")
end


function UILoginPanel:on_show(is_new_show, panel_data)
    log_info("UILoginPanel:on_show")
    self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.login_done, Functional.make_closure(self.on_event_login_cnn_done, self))
    self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.open, Functional.make_closure(self.on_event_login_cnn_open, self))
    self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.close, Functional.make_closure(self.on_event_login_cnn_close, self))
end

function UILoginPanel:on_hide()
    log_info("UILoginPanel:on_hide")
    self.ml_event_subscriber:release_all()
end


function UILoginPanel:on_click_cnn_btn()
    local login_cnn_logic = g_ins.login_cnn_logic
    local cnn_state = login_cnn_logic:get_state()
    log_debug("UILoginPanel:on_click_cnn_btn state is %s", cnn_state)
    if Net_Agent_State.free == cnn_state or Net_Agent_State.closed == cnn_state then
        login_cnn_logic:set_account_id(self.account_id_txt:get_text())
        login_cnn_logic:reset(self.ip_txt:get_text(), tonumber(self.port_txt:get_text()))
        login_cnn_logic:connect()
    else
        log_error("login_cnn_logic in state %s", cnn_state)
    end
end

function UILoginPanel:on_click_reset_btn()
    log_info("UILoginPanel:on_click_reset_btn")
    local login_cnn_logic = g_ins.login_cnn_logic
    login_cnn_logic:reset(self.ip_txt:get_text(), tonumber(self.port_txt:get_text()))
    self.notify_txt:set_text("")
end

function UILoginPanel:on_event_login_cnn_done(cnn_logic, error_code, user_info)
    log_info("UILoginPanel:on_event_login_cnn_done")
    self.user_info = user_info
    if 0 ~= error_code then
        self.notify_txt:set_text(string.format("get user info from login game fail. error_code is %s", error_code))
    end
end

function UILoginPanel:on_event_login_cnn_open(cnn_logic, is_succ)
    log_info("UILoginPanel:on_event_login_cnn_open %s", is_succ)
    if not is_succ then
        self.notify_txt:set_text("connect login server fail")
    end
end

function UILoginPanel:on_event_login_cnn_close(cnn_logic, error_code, error_msg)
    if not cnn_logic:is_done() and Error_None ~= error_code then
        self.notify_txt:set_text(string.format( "login connection closed unexpected ! error_msg : %s ", error_msg))
    end
end




