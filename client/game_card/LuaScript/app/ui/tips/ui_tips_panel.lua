
---@class UITipsPanel:UIPanelBase
UITipsPanel = UITipsPanel or class("UITipsPanel", UIPanelBase)

function UITipsPanel:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)
    ---@type UITipsDataWrap
    self._wrap_data = nil
end

function UITipsPanel:_on_init()
    UITipsPanel.super._on_init(self)
end

function UITipsPanel:_on_attach_panel()
    UITipsPanel.super._on_attach_panel(self)

    ---@type UIText
    self._content_txt = UIHelp.attach_ui(UIText, self._panel_root, "ContentTxt")
end

function UITipsPanel:_on_open(panel_data)
    UITipsPanel.super._on_open(self, panel_data)
    self._wrap_data = panel_data
end

function UITipsPanel:_on_show_panel()
    self._content_txt:set_text(self._wrap_data.data.str_content)
end






