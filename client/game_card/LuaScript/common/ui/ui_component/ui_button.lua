
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

