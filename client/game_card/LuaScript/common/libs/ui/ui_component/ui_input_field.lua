
UIInputIField = UIInputIField or class("UIInputIField", UIComponent)

function UIInputIField:ctor(go)
    self._input_field_comp = UIHelp.get_component(CSharpType.UIInputField, go)
    assert(CSharpHelp.not_null(self._input_field_comp))
    UIInputIField.super.ctor(self, go)
end

function UIInputIField:is_available()
    if not UIInputIField.super.is_available(self) then
        return false
    end
    if CSharpHelp.is_null(self._input_field_comp) then
        return false
    end
    return true
end

function UIInputIField:set_text(text_str)
    if not self:is_available() then
        return false
    end
    local real_text_str = tostring(text_str)
    self._input_field_comp.text = tostring(real_text_str)
    return true
end

function UIInputIField:get_text()
    if not self:is_available() then
        return ""
    end
    return self._input_field_comp.text
end

function UIInputIField:set_color(color)
    if CSharpHelp.is_null(color) or not self:is_available() then
        return false
    end
    self._input_field_comp.color = color
    return true
end

function UIInputIField:on_destroy()
    UIInputIField.super.on_destroy(self)
    self._input_field_comp = nil
end

-- todo: add event APIs
