
UIComponent = UIComponent or class("UIComponent")

function UIComponent:ctor(go)
    print("UIComponent:actor")
    self.unique_id = gen_next_seq()
    self.comp = UIHelp.get_or_add_component(CSharpType.LuaUIComponent, go)
    self.comp:Register(self)
    self.is_attached = true
end

function UIComponent:release()
    if CSharpHelp.not_null(self.comp) then
        self.comp:Unregister(self)
    end
    self.is_attached = false
end

function UIComponent:on_enable()
    log_debug("UIComponent:on_enable")
end

function UIComponent:on_disable()
    log_debug("UIComponent:on_disable")
end

function UIComponent:on_destroy()
    log_debug("UIComponent:on_destroy")
end

function UIComponent:set_active(is_active)
    if not self:is_available() then
        return false
    end
    self.comp.gameObjcet:SetActive(is_active and true or false)
    return true
end

function UIComponent:get_active()
    if not self:is_available() then
        return false
    end
    return self.comp.gameObjcet.activeSelf
end

function UIComponent:is_available()
    if not self.is_attached then
        return false
    end
    if CSharpHelp.is_null(self.comp) then
        return false
    end
    return true
end

function UIComponent:_csharp_cb_on_destroy()
    if not self.is_attached then
        return
    end
    log_debug("UIComponent:_csharp_cb_on_destroy")
    self:on_destroy()
    self.comp = nil
    self.is_attached = false
end

function UIComponent:_csharp_cb_on_enable()
    if not self:is_available() then
        return
    end
    log_debug("UIComponent:_csharp_cb_on_enable")
    self:on_enable()
end

function UIComponent:_csharP_cb_on_disable()
    if not self:is_available() then
        return
    end
    log_debug("UIComponent:_csharP_cb_on_disable")
    self:on_disable()
end

