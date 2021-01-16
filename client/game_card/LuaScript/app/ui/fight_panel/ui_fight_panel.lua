
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

    ---@type UIButton
    self._close_btn = UIHelp.attach_ui(UIButton, self._panel_root, "close_btn")
    self._close_btn:set_onclick(Functional.make_closure(self._on_click_close_btn, self))
end

function UIFightPanel:_update_match_view()

end

function UIFightPanel:_on_click_close_btn()
    self.app.panel_mgr:close_panel(UI_Panel_Name.fight_panel)
    self.app.logic_mgr.fight:exit_fight()
end











