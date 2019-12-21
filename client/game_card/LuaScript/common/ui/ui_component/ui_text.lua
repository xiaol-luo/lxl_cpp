
UIText = UIText or class("UIText", UIComponent)

function UIText:ctor(go)
    self.text_comp = UIHelp.get_component(CSharpType.UIText, go)
    assert(CSharpHelp.not_null(self.text_comp))
    UIText.super.ctor(self, go)
end

function UIText:is_available()
    if not UIText.super.is_available(self) then
        return false
    end
    if CSharpHelp.is_null(self.text_comp) then
        return false
    end
    return true
end

function UIText:set_text(text_str)
    if not self:is_available() then
        return false
    end
    local real_text_str = tostring(text_str)
    self.text_comp.text = tostring(real_text_str)
    return true
end

function UIText:get_text()
    if not self:is_available() then
        return ""
    end
    return self.text_comp.text
end

function UIText:set_color(color)
    if CSharpHelp.is_null(color) or not self:is_available() then
        return false
    end
    self.text_comp.color = color
    return true
end

function UIText:get_color()
    if not self:is_available() then
        return nil
    end
    return self.text_comp.color
end
