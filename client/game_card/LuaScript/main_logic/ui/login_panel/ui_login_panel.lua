
UILoginPanel = UILoginPanel or class("UILoginPanel", UIPanelBase)

function UILoginPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self.btn_click_times = 0
    self.panel_data = nil
    self.login_view = nil
    self.ip_txt = nil
    self.port_txt = nil
    self.cnn_btn = nil
    self.reset_btn = nil
    self.gate_view = nil
    self.login_view = nil
    self.confirm_login_btn = nil
    self.cancel_login_btn = nil
    self.notify_txt = nil
    self.ml_event_subscriber = nil
    self.user_info = nil
end

function UILoginPanel:init()
    log_debug("UILoginPanel:init")
    self.super.init(self)

    self.ml_event_subscriber = g_ins.event_mgr:create_subscriber()
    self.login_view = UIHelp.find_gameobject(self.root_go, "LoginView")
    self.ip_txt = UIHelp.attach_ui(UIText, self.root_go, "LoginView/Ip/Text")
    self.port_txt = UIHelp.attach_ui(UIText, self.root_go, "LoginView/Port/Text")
    self.cnn_btn = UIHelp.attach_ui(UIButton, self.root_go, "LoginView/ConnectBtn")
    self.cnn_btn:set_onclick(Functional.make_closure(self.on_click_cnn_btn, self))
    self.reset_btn = UIHelp.attach_ui(UIButton, self.root_go, "LoginView/ResetBtn")
    self.reset_btn:set_onclick(Functional.make_closure(self.on_click_reset_btn, self))

    self.gate_view = UIHelp.find_gameobject(self.root_go, "GateView")
    self.confirm_login_btn = UIHelp.attach_ui(UIButton, self.root_go, "GateView/ConfirmBtn")
    self.confirm_login_btn:set_onclick(Functional.make_closure(self.on_click_confirm_login_btn, self))

    self.cancel_login_btn = UIHelp.attach_ui(UIButton, self.root_go, "GateView/CancelBtn")
    self.cancel_login_btn:set_onclick(Functional.make_closure(self.on_click_cancel_login_btn, self))
    self.user_name_txt = UIHelp.attach_ui(UIText, self.root_go, "GateView/UserName")

    self.notify_txt = UIHelp.attach_ui(UIText, self.root_go, "NotifyTxt")
end


function UILoginPanel:on_show(is_new_show, panel_data)
    log_info("UILoginPanel:on_show")
    self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.login_done, Functional.make_closure(self.on_event_login_cnn_done, self))
    self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.open, Functional.make_closure(self.on_event_login_cnn_open, self))
end

function UILoginPanel:on_hide()
    log_info("UILoginPanel:on_hide")
    self.ml_event_subscriber:release_all()
end


function UILoginPanel:on_click_cnn_btn()
    log_debug("UILoginPanel:on_click_cnn_btn ip: %s, port: %s", self.ip_txt:get_text(), self.port_txt:get_text())
    self.btn_click_times = self.btn_click_times + 1
    local login_cnn_logic = g_ins.login_cnn_logic
    local cnn_state = login_cnn_logic:get_state()
    log_debug("UILoginPanel:on_click_cnn_btn state is %s", cnn_state)
    for k, v in pairs(Net_Agent_State) do
        -- log_debug("%s = %s", k, v)
    end
    if Net_Agent_State.free == cnn_state or Net_Agent_State.closed == cnn_state then
        login_cnn_logic:reset(self.ip_txt:get_text(), tonumber(self.port_txt:get_text()))
        login_cnn_logic:connect()
    else
        -- log_error("login_cnn_logic in state %s", cnn_state)
    end
end

function UILoginPanel:on_click_reset_btn()
    log_info("UILoginPanel:on_click_reset_btn")
    local login_cnn_logic = g_ins.login_cnn_logic
    login_cnn_logic:reset(self.ip_txt:get_text(), tonumber(self.port_txt:get_text()))
    self.notify_txt:set_text("")
end

function UILoginPanel:on_click_confirm_login_btn()
    log_info("UILoginPanel:on_click_confirm_login_btn")
    local user_info = g_ins.login_cnn_logic.user_info
    if user_info then
        g_ins.gate_cnn_logic:set_user_info(user_info.gate_ip, user_info.gate_port, user_info.user_id,
                user_info.auth_sn, user_info.auth_ip, user_info.auth_port, user_info.account_id, user_info.app_id)
        g_ins.gate_cnn_logic:connect()
    end
end

function UILoginPanel:on_click_cancel_login_btn()
    log_info("UILoginPanel:on_click_cancel_login_btn")
    self.gate_view:SetActive(false)
    self.login_view:SetActive(true)
end

function UILoginPanel:on_event_login_cnn_done(cnn_logic, error_code, user_info)
    log_info("UILoginPanel:on_event_login_cnn_done")
    self.user_info = user_info
    if 0 ~= error_code then
        self.notify_txt:set_text(string.format("get user info from login game fail. error_code is %s", error_code))
    else
        self.gate_view:SetActive(true)
        self.login_view:SetActive(false)
        self.user_name_txt:set_text(user_info.user_id)
    end
end

function UILoginPanel:on_event_login_cnn_open(cnn_logic, is_succ)
    log_info("UILoginPanel:on_event_login_cnn_open %s", is_succ)
    if not is_succ then
        self.notify_txt:set_text("connect login server fail")
    end
end




