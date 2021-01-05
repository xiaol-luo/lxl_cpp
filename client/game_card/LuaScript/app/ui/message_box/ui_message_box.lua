
---@class UIMessageBox:UIPanelBase
UIMessageBox = UIMessageBox or class("UIMessageBox", UIPanelBase)

function UIMessageBox:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)

end

function UIMessageBox:_on_init()
    UIMessageBox.super._on_init(self)
end

function UIMessageBox:_on_attach_panel()
    UIMessageBox.super._on_attach_panel(self)
end

function UIMessageBox:_on_open(panel_data)
    UIMessageBox.super._on_open(self, panel_data)
end

function UIMessageBox:_on_enable()
    UIMessageBox.super._on_enable(self)
end

function UIMessageBox:_on_disable()
    UIMessageBox.super._on_disable(self)
end

function UIMessageBox:_on_release()
    UIMessageBox.super._on_release(self)
end






