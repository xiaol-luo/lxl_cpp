
---@class UIMessageBox:UIPanelBase
UIMessageBox = UIMessageBox or class("UIMessageBox", UIPanelBase)

function UIMessageBox:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)
    ---@type UIMessageDataWrap
    self._data_wrap = nil
end

function UIMessageBox:_on_init()
    UIMessageBox.super._on_init(self)
end

function UIMessageBox:_on_attach_panel()
    UIMessageBox.super._on_attach_panel(self)

    ---@type UIButton
    self._confirm_btn = UIHelp.attach_ui(UIButton, self._panel_root, "Buttons/ConfirmBtn")
    self._confirm_btn:set_onclick(Functional.make_closure(self._on_click_confirm_btn, self))
    ---@type UIText
    self._confirm_txt = UIHelp.attach_ui(UIText, self._panel_root, "Buttons/ConfirmBtn/Text")

    ---@type UIButton
    self._cancel_btn = UIHelp.attach_ui(UIButton, self._panel_root, "Buttons/CancelBtn")
    self._cancel_btn:set_onclick(Functional.make_closure(self._on_click_confirm_btn, self))
    ---@type UIText
    self._cancel_txt = UIHelp.attach_ui(UIText, self._panel_root, "Buttons/CancelBtn/Text")

    ---@type UIButton
    -- self._close_btn = UIHelp.attach_ui(UIButton, self._panel_root, "Buttons/CloseBtn")
    -- self._close_btn:set_onclick(Functional.make_closure(self._on_click_confirm_btn, self))

    ---@type UIText
    self._content_txt = UIHelp.attach_ui(UIText, self._panel_root, "ContentTxt")

    log_print("UIMessageBox.super._on_attach_panel")
end

function UIMessageBox:_on_open(panel_data)
    UIMessageBox.super._on_open(self, panel_data)
    self._wrap_data = panel_data
end

function UIMessageBox:_on_show_panel()
    self._content_txt:set_text(self._wrap_data.data.str_content)
    self._confirm_txt:set_text(self._wrap_data.data.str_confirm)
    self._cancel_txt:set_text(self._wrap_data.data.str_cancel)
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

function UIMessageBox:_on_click_confirm_btn()
    self._wrap_data.confirm_cb()
end

function UIMessageBox:_on_click_cancel_btn()
    self._wrap_data.cancel_cb()
end

function UIMessageBox:_on_click_close_btn()
    self._wrap_data.close_cb()
end




