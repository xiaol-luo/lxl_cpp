
UIMainPanel = UIMainPanel or class("UIMainPanel", UIPanelBase)

function UIMainPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
end

function UIMainPanel:init()
    log_debug("UIMainPanel:init")
    self.super.init(self)
    self.btn_txt = UIHelp.attach_ui(UIText, self.root_go, "NetBtn/Text")
    self.btn_txt:set_text("1234")
    self.btn_txt:set_color(UIHelp.new_color(1, 2, 3))
end





