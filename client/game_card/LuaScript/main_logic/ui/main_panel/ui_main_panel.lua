
UIMainPanel = UIMainPanel or class("UIMainPanel", UIPanelBase)

function UIMainPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self.btn_click_times = 0
    self.panel_data = nil
end

function UIMainPanel:init()
    log_debug("UIMainPanel:init")
    self.super.init(self)
    self.ip_txt = UIHelp.attach_ui(UIText,self.root_go, "Ip/Text")
    self.port_txt = UIHelp.attach_ui(UIText,self.root_go, "Port/Text")

    self.btn_txt = UIHelp.attach_ui(UIText, self.root_go, "NetBtn/Text")
    -- self.btn_txt:set_text("1234")
    -- self.btn_txt:set_color(UIHelp.new_color(0.3, 0.3, 0.3))
    self.img = UIHelp.attach_ui(UIImage, self.root_go, "Image")

    self.btn = UIHelp.attach_ui(UIButton, self.root_go, "NetBtn")
    self.btn:set_onclick(Functional.make_closure(self.on_click_btn, self))
end

function UIMainPanel:on_click_btn()
    log_debug("UIMainPanel:on_click_btn ip: %s, port: %s", self.ip_txt:get_text(), self.port_txt:get_text())
    self.btn_click_times = self.btn_click_times + 1
    local login_cnn_logic = g_ins.login_cnn_logic
    local cnn_state = login_cnn_logic:get_state()
    log_debug("UIMainPanel:on_click_btn state is %s", cnn_state)
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

function UIMainPanel:on_show(panel_data)
    self.panel_data = panel_data
end







