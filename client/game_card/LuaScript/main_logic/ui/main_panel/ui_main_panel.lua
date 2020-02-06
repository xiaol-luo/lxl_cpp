
UIMainPanel = UIMainPanel or class("UIMainPanel", UIPanelBase)

function UIMainPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self.panel_data = nil
end

function UIMainPanel:init()
    log_debug("UIMainPanel:init")
    self.super.init(self)
    self.query_btn = nil
end

function UIMainPanel:on_show(panel_data)
    self.panel_data = panel_data
    self.query_btn = UIHelp.attach_ui(UIButton, self.root_go, "RefreshMatchInfoBtn")
    self.query_btn:set_onclick(Functional.make_closure(self._on_click_query_btn, self))
end

function UIMainPanel:_on_click_query_btn()
    local ret = g_ins.gate_cnn_logic:send_msg_to_game(ProtoId.pull_role_data, { pull_type = 0 })
    log_debug("UIMainPanel:_on_click_query_btn %s", ret)
end







