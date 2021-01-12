
---@class UIButton:UIComponent
UIButton = UIButton or class("UIButton", UIComponent)

function UIButton:ctor(go)
    self.btn_comp = UIHelp.get_component(CSharpType.UIButton, go)
    assert(CSharpHelp.not_null(self.btn_comp))
    UIButton.super.ctor(self, go)
end

function UIButton:is_available()
    if not UIButton.super.is_available(self) then
        return false
    end
    if CSharpHelp.is_null(self.btn_comp) then
        return false
    end
    return true
end

function UIButton:set_onclick(fn)
    if not self:is_available() then
        return
    end
    self:clear_onclick()
    self.onclick_cb = fn
    self.btn_comp.onClick:AddListener(self.onclick_cb)
end

function UIButton:clear_onclick()
    if self.onclick_cb then
        if self:is_available() then
            self.btn_comp.onClick:RemoveListener(self.onclick_cb)
        end
        self.onclick_cb = nil
    end
end

function UIButton:do_click()
    if not self:is_available() then
        return
    end
    self.btn_comp.onClick:Invoke()
end

function UIButton:on_destroy()
    UIButton.super.on_destroy(self)
    self.btn_comp = nil
    self.onclick_cb = nil
end

function UIButton:release()
    self:clear_onclick()
    UIButton.super.release(self)
end