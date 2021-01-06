
---@class UITipsPanel:UIPanelBase
UITipsPanel = UITipsPanel or class("UITipsPanel", UIPanelBase)

function UITipsPanel:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)
end

function UITipsPanel:_on_init()
    UITipsPanel.super._on_init(self)
end

function UITipsPanel:_on_attach_panel()
    UITipsPanel.super._on_attach_panel(self)

    self._confirm_btn = nil
    self._cancel_btn = nil
    self._content_txt = nil
end

function UITipsPanel:_on_open(panel_data)
    UITipsPanel.super._on_open(self, panel_data)
end

function UITipsPanel:_on_enable()
    UITipsPanel.super._on_enable(self)
end

function UITipsPanel:_on_disable()
    UITipsPanel.super._on_disable(self)
end

function UITipsPanel:_on_release()
    UITipsPanel.super._on_release(self)
end






