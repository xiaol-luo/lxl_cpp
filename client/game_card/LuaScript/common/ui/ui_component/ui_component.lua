
UIComponent = UIComponent or class("UIComponent")

function UIComponent:ctor(go)
    print("UIComponent:actor")
    self.unique_id = gen_next_seq()
    self.go = go
    self.comp = UIHelp.get_or_add_component(CSharpType.LuaUIComponent, self.go)
    self:_attach()
end

function UIComponent:release()
    self:_deattach()
end

function UIComponent:on_enable()

end

function UIComponent:on_disable()

end

function UIComponent:on_destroy()

end

function UIComponent:_attach()
    self.comp:Register(self)
end

function UIComponent:_deattach()
    self.comp:Unregister(self)
end

function UIComponent:_csharp_cb_on_destroy()
    log_debug("UIComponent:_csharp_cb_on_destroy")
end

function UIComponent:_csharp_cb_on_enable()
    log_debug("UIComponent:_csharp_cb_on_enable")
end

function UIComponent:_csharP_cb_on_disable()
    log_debug("UIComponent:_csharP_cb_on_disable")
end