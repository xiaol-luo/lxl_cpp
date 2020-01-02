
UIMainPanel = UIMainPanel or class("UIMainPanel", UIPanelBase)

function UIMainPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self.btn_click_times = 0
end

function UIMainPanel:init()
    log_debug("UIMainPanel:init")
    self.super.init(self)
    self.ip_txt = UIHelp.attach_ui(UIText,self.root_go, "Ip/Text")
    self.port_txt = UIHelp.attach_ui(UIText,self.root_go, "Port/Text")

    self.btn_txt = UIHelp.attach_ui(UIText, self.root_go, "NetBtn/Text")
    self.btn_txt:set_text("1234")
    self.btn_txt:set_color(UIHelp.new_color(0.3, 0.3, 0.3))
    self.img = UIHelp.attach_ui(UIImage, self.root_go, "Image")

    self.btn = UIHelp.attach_ui(UIButton, self.root_go, "NetBtn")
    self.btn:set_onclick(Functional.make_closure(self.on_click_btn, self, "click btn 1"))
    self.btn:do_click()
    self.btn:clear_onclick()
    self.btn:do_click()
    self.btn:set_onclick(Functional.make_closure(self.on_click_btn, self, "click btn 2"))
    self.btn:do_click()
end

function UIMainPanel:on_click_btn(custom_param)
    log_debug("UIMainPanel:on_click_btn ip: %s, port: %s", self.ip_txt:get_text(), self.port_txt:get_text())
    self.btn_click_times = self.btn_click_times + 1
    if self.btn_click_times % 2 == 0 then
        self.img:set_sprite("Assets/Res/UI/Images/2.png")
    else
        self.img:set_sprite("Assets/Res/UI/Images/1.png")
    end
end







