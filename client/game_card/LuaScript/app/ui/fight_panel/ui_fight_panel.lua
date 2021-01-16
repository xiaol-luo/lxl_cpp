
---@class UIFightPanel:UIPanelBase
UIFightPanel = UIFightPanel or class("UIFightPanel", UIPanelBase)

function UIFightPanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)
    self._main_role = self.app.data_mgr.main_role
end

function UIFightPanel:_on_init()
    UIFightPanel.super._on_init(self)
    log_debug("UIFightPanel:_on_init")
end

function UIFightPanel:_on_attach_panel()
    UIFightPanel.super._on_attach_panel(self)
end

function UIFightPanel:_update_match_view()
end











