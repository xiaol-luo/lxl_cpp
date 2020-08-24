
---@class UIPanelBase:EventMgr
UIPanelBase = UIPanelBase or class("UIPanelBase", EventMgr)

function UIPanelBase:ctor(panel_mgr, panel_setting)
    UIPanelBase.super.ctor(self)
    ---@type UIPanelMgr
    self._panel_mgr = panel_mgr
    ---@type LuaApp
    self._app = g_ins
    self._panel_setting = panel_setting
    self._panel_state = Panel_State.free

    self._res_loader = CS.Lua.LuaResLoaderProxy.Create()
    ---@type EventBinder
    self._event_binder = EventBinder:new()

    self._root = nil -- root of panel /
    self._wrap_root = nil -- /Root
    self._panel_root_parent = nil -- /Root/PanelRoot
    self._panel_root = nil -- /Root/PanelRoot/$panel_name

    self._is_attached_panel = false
    self._open_tmes = 0
end

function UIPanelBase:init()
    self._root = self._panel_mgr.panel_wrapper_res_obs:Instantiate()
    self._root.name = string.format("%s_wrapper", self._panel_setting.panel_name)
    self._wrap_root = UIHelp.find_gameobject(self._root, "Root")
    self._panel_root_parent = UIHelp.find_gameobject(self._root, "Root/PanelRoot")
    local belong_layer = self._panel_mgr.layers[self._panel_setting.belong_layer]
    assert(belong_layer)
    UIHelp.set_parent(self._root, belong_layer)
    self:_load_panel_res()

    self._panel_state = Panel_State.disable
    self:_on_init()
end

function UIPanelBase:_load_panel_res()
    self._res_loader:AsyncLoadAsset(self._panel_setting.res_path, function(res_path, res_obs)
        if self:is_released() then
            self._res_loader:Release()
            return
        end
        if not res_obs.isValid then
            log_assert(false, "panel %s load resource fail, path is %s", self._panel_setting.panel_name, res_path)
        end
        -- self.panel_state = Panel_State.loaded
        local panel_root = res_obs:Instantiate()
        self:_attach_panel(panel_root)
    end)
end

function UIPanelBase:open(panel_data)
    if self:is_released() then
        return
    end

    self._open_tmes = self._open_tmes + 1
    self:fire(Panel_Event.pre_open, self)
    self:_on_open(panel_data)
    self:fire(Panel_Event.open, self)
    self:enable()
end

function UIPanelBase:_attach_panel(panel_go)
    self._is_attached_panel = true
    self._panel_root = panel_go
    self._panel_root.name = self._panel_setting.panel_name
    UIHelp.set_parent(self._panel_root, self._panel_root_parent)
    self:_on_attach_panel()
end

function UIPanelBase:enable()
    if self:is_released() or self:is_enable() then
        return
    end

    self._panel_state = Panel_State.enable
    self._root:SetActive(true)
    self:fire(Panel_Event.pre_enable, self)
    self:_on_enable()
    self:fire(Panel_Event.enable, self)
end

function UIPanelBase:disable()
    if self:is_released() or self:is_disable() then
        return
    end

    self._panel_state = Panel_State.disable
    self._root:SetActive(false)
    self:fire(Panel_Event.pre_disable, self)
    self:_on_disable()
    self:fire(Panel_Event.disable, self)
end

function UIPanelBase:release()
    if self:is_released() then
        return
    end

    self:disable()
    self._panel_state = Panel_State.released
    self:fire(Panel_Event.pre_release, self)
    self:_on_release()
    self:fire(Panel_Event.release, self)
    self._res_loader:Release()
    self:cancel_all()
    self._event_binder:release_all()
    UIHelp.destroy_gameobject(self._root)
end

function UIPanelBase:get_setting()
    return self._panel_setting
end

function UIPanelBase:get_name()
    return self._panel_setting.panel_name
end

function UIPanelBase:get_state()
    return self.panel_wrapper:get_state()
end

function UIPanelBase:get_root()
    return self.root_go
end

function UIPanelBase:is_released()
    return Panel_State.released == self._panel_state
end

function UIPanelBase:is_enable()
    return Panel_State.enable == self._panel_state
end

function UIPanelBase:is_disable()
    return Panel_State.disable == self._panel_state
end

function UIPanelBase:_on_init()

end

function UIPanelBase:_on_attach_panel()

end

function UIPanelBase:_on_open(panel_data)

end

function UIPanelBase:_on_enable()

end

function UIPanelBase:_on_disable()
end

function UIPanelBase:_on_release()

end

function UIPanelBase:get_open_times()
    return self._open_tmes
end

