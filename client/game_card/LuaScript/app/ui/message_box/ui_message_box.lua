
---@class UIMessageBox:UIPanelBase
UIMessageBox = UIMessageBox or class("UIMessageBox", UIPanelBase)

function UIMessageBox:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)
    ---@type UIMessageBoxDataWrap
    self._wrap_data = nil
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
    self._refuse_btn = UIHelp.attach_ui(UIButton, self._panel_root, "Buttons/RefuseBtn")
    self._refuse_btn:set_onclick(Functional.make_closure(self._on_click_refuse_btn, self))
    ---@type UIText
    self._refuse_txt = UIHelp.attach_ui(UIText, self._panel_root, "Buttons/RefuseBtn/Text")

    ---@type UIButton
    self._ignore_btn = UIHelp.attach_ui(UIButton, self._panel_root, "Buttons/IgnoreBtn")
    self._ignore_btn:set_onclick(Functional.make_closure(self._on_click_ignore_btn, self))
    ---@type UIText
    self._ignore_txt = UIHelp.attach_ui(UIText, self._panel_root, "Buttons/IgnoreBtn/Text")

    ---@type UIButton
    self._close_btn = UIHelp.attach_ui(UIButton, self._panel_root, "CloseBtn")
    self._close_btn:set_onclick(Functional.make_closure(self._on_click_close_btn, self))

    ---@type UIText
    self._content_txt = UIHelp.attach_ui(UIText, self._panel_root, "ContentTxt")
    ---@type UIText
    self._title_txt = UIHelp.attach_ui(UIText, self._panel_root, "TitleTxt")

    log_print("UIMessageBox.super._on_attach_panel")
end

function UIMessageBox:_on_open(panel_data)
    UIMessageBox.super._on_open(self, panel_data)
    self._wrap_data = panel_data
end

function UIMessageBox:_on_show_panel()
    self._title_txt:set_text(self._wrap_data.data.str_title)
    self._content_txt:set_text(self._wrap_data.data.str_content)
    self._confirm_txt:set_text(self._wrap_data.data.str_confirm)
    self._refuse_txt:set_text(self._wrap_data.data.str_refuse)
    self._ignore_txt:set_text(self._wrap_data.data.str_ignore)

    self._confirm_btn:set_active(false)
    self._refuse_btn:set_active(false)
    self._ignore_btn:set_active(false)
    self._close_btn:set_active(false)

    local view_type = self._wrap_data.data.view_type
    if MessageBoxViewType.confirm then
        self._confirm_btn:set_active(true)
    end

    if MessageBoxViewType.refuse_confirm then
        self._confirm_btn:set_active(true)
        self._refuse_btn:set_active(true)
    end

    if MessageBoxViewType.ignore_confirm then
        self._confirm_btn:set_active(true)
        self._close_btn:set_active(true)
        if #self._wrap_data.data.str_ignore > 0 then
            self._ignore_btn:set_active(true)
        else
            self._ignore_btn:set_active(false)
        end
    end

    if MessageBoxViewType.refuse_ignore_confirm then
        self._confirm_btn:set_active(true)
        self._refuse_btn:set_active(true)
        self._close_btn:set_active(true)
        if #self._wrap_data.data.str_ignore > 0 then
            self._ignore_btn:set_active(true)
        else
            self._ignore_btn:set_active(false)
        end
    end
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
    self._wrap_data.cb_confirm()
end

function UIMessageBox:_on_click_refuse_btn()
    self._wrap_data.cb_refuse()
end

function UIMessageBox:_on_click_ignore_btn()
    self._wrap_data.cb_ignore()
end

function UIMessageBox:_on_click_close_btn()
    self._wrap_data.cb_ignore()
end




