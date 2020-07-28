
UIPanelMgr = UIPanelMgr or class("UIPanelMgr")

UIPanelMgr.Const = UIPanelMgr.Const or {
    Preload_Res_List = {
        Panel_Wrapper_Prefab_Path = "Assets/Res/UI/PanelMgr/UIPanelProxy.prefab",
    }
}

function UIPanelMgr:ctor()
    self.res_loader = nil
    self.event_mgr = nil
    self.timer_proxy = nil
    self.root_go = nil
    self.already_prepare_assets = false
    self.cached_panels = {}
    self.panel_wrapper_res_obs = nil
    self.layers = {}
end

function UIPanelMgr:init(root_go)
    self.root_go = root_go
    assert(self.root_go)
    self.res_loader = CS.Lua.LuaResLoaderProxy.Create()
    self.event_mgr = EventMgr:new()
    self.timer_proxy = TimerProxy:new()

    for layer_name, layer_setting in pairs(UI_Panel_Layer_Setting) do
        self.layers[layer_name] = UIHelp.find_transform(self.root_go, layer_setting.relative_path)
    end
    print("layers ", self.layers)
end

function UIPanelMgr:prepare_assets()
    if self.already_prepare_assets then
        return
    end
    self.already_prepare_assets = true
    for _, v in pairs(UIPanelMgr.Const.Preload_Res_List) do
        local res_obs = self.res_loader:LoadAsset(v)
        if v == UIPanelMgr.Const.Preload_Res_List.Panel_Wrapper_Prefab_Path then
            self.panel_wrapper_res_obs = res_obs
            assert(self.panel_wrapper_res_obs.isDone)
        end
    end
end

function UIPanelMgr:show_panel(panel_name, panel_data)
    local panel_wrapper = self:_get_cached_panel(panel_name)
    if not panel then
        local panel_setting = UI_Panel_Setting[panel_name]
        assert(panel_setting)
        panel_wrapper = UIPanelWrapper:new(self, panel_setting)
        self.cached_panels[panel_name] = panel_wrapper
        panel_wrapper:init()
    end
    panel_wrapper:show(panel_data)
end

function UIPanelMgr:reshow_panel(panel_name)
    local panel_wrapper = self:_get_cached_panel(panel_name)
    if panel_wrapper then
        panel_wrapper:reshow()
    end
    return panel_wrapper
end

function UIPanelMgr:hide_panel(panel_name)
    local panel_wrapper = self:_get_cached_panel(panel_name)
    if panel_wrapper then
        panel_wrapper:hide()
    end
    return panel_wrapper
end

function UIPanelMgr:hide_all_panel()
    for _, v in pairs(self.cached_panels) do
        v:hide()
    end
end

function UIPanelMgr:release_panel(panel_name)
    local panel_wrapper = self:_get_cached_panel(panel_name)
    if panel_wrapper then
        panel_wrapper:release()
    end
    return panel_wrapper
end

function UIPanelMgr:release_all_panel()
    for _, v in pairs(self.cached_panels) do
        v:release()
    end
    self.cached_panels = {}
end

function UIPanelMgr:release_self()
    self:release_all_panel()
    self.res_loader:Release()
    self.event_mgr:cancel_all()
    self.timer_proxy:release_all()
end

function UIPanelMgr:_get_cached_panel(panel_name)
    local ret = self.cached_panels[panel_name]
    return ret
end











