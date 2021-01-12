
---@class UIPanelMgr:EventMgr
UIPanelMgr = UIPanelMgr or class("UIPanelMgr", EventMgr)

UIPanelMgr.Const = UIPanelMgr.Const or {
    Preload_Res_List = {
        Panel_Wrapper_Prefab_Path = "Assets/Res/UI/PanelMgr/UIPanelProxy.prefab",
    }
}

function UIPanelMgr:ctor()
    UIPanelMgr.super.ctor(self)
    self._res_loader = nil
    self._timer_proxy = nil
    self._root_go = nil
    self._already_prepare_assets = false
    self._cached_panel_datas = {}
    self.panel_wrapper_res_obs = nil
    self.layers = {}
    self._event_binder = EventBinder:new()
    self._cached_forward_panel_event_closure = {}
end

function UIPanelMgr:init(_root_go)
    self._root_go = _root_go
    assert(self._root_go)
    self._res_loader = CS.Lua.LuaResLoaderProxy.Create()
    self._timer_proxy = TimerProxy:new()

    for layer_name, layer_setting in pairs(Panel_Layer_Setting) do
        self.layers[layer_name] = UIHelp.find_transform(self._root_go, layer_setting.relative_path)
    end
    print("layers ", self.layers)
end

function UIPanelMgr:prepare_assets()
    if self._already_prepare_assets then
        return
    end
    self._already_prepare_assets = true
    for _, v in pairs(UIPanelMgr.Const.Preload_Res_List) do
        local res_obs = self._res_loader:LoadAsset(v)
        if v == UIPanelMgr.Const.Preload_Res_List.Panel_Wrapper_Prefab_Path then
            self.panel_wrapper_res_obs = res_obs
            assert(self.panel_wrapper_res_obs.isDone)
        end
    end
end

function UIPanelMgr:open_panel(panel_name, open_param)
    self:close_panel(panel_name, true)
    ---@type UIPanelBase
    local panel_data = self:_get_cached_panel_data(panel_name)
    if not panel_data then
        local panel_setting = UI_Panel_Setting[panel_name]
        assert(panel_setting)
        local panel = panel_setting.panel_cls:new(self, panel_setting)
        panel:init()
        panel_data = {
            panel_name = panel:get_name(),
            panel = panel,
            event_bind_ids = {},
        }
        self:_bind_panel_events(panel_data, true)
        self._cached_panel_datas[panel_name] = panel_data
    end
    panel_data.panel:open(open_param)
end

function UIPanelMgr:enable_panel(panel_name)
    local panel_data = self:_get_cached_panel_data(panel_name)
    if panel_data then
        panel_data.panel:enable()
    end
end

function UIPanelMgr:disable_panel(panel_name)
    local panel_data = self:_get_cached_panel_data(panel_name)
    if panel_data then
        panel_data.panel:disable()
    end
end

function UIPanelMgr:disable_all_panel()
    for _, v in pairs(self._cached_panel_datas) do
        v.panel:disable()
    end
end

function UIPanelMgr:close_panel(panel_name, is_cache)
    if not is_cache then
        local panel_data = self:_get_cached_panel_data(panel_name)
        if panel_data then
            self:_do_release_panel(panel_data)
            self._cached_panel_datas[panel_name] = nil
        end
    else
        self:disable_panel(panel_name)
    end
end

function UIPanelMgr:close_all_panel()
    for _, v in pairs(self._cached_panel_datas) do
        self:_do_release_panel(v)
    end
    self._cached_panel_datas = {}
end

function UIPanelMgr:_do_release_panel(panel_data)
    if not panel_data then
        return
    end

    panel_data.panel:release()
    self:_bind_panel_events(panel_data, false)
end

function UIPanelMgr:release_self()
    self:close_all_panel()
    self._res_loader:Release()
    self._timer_proxy:release_all()
    self._cached_forward_panel_event_closure = {}
    self:cancel_all()
end

function UIPanelMgr:_get_cached_panel_data(panel_name)
    local ret = self._cached_panel_datas[panel_name]
    return ret
end

function UIPanelMgr:_forward_panel_events(combine_event_name, event_name, panel, ...)
    self:fire(event_name, panel, ...)
    self:fire(combine_event_name, panel, ...)
    -- log_print("UIPanelMgr:_forward_panel_events ", combine_event_name, event_name, ...)
end

function UIPanelMgr:_bind_panel_events(panel_data, is_bind)
    self._event_binder:batch_cancel(panel_data.event_bind_ids)
    panel_data.event_bind_ids = {}

    if is_bind then
        local ev_name_fns = {}
        for _, event_name in pairs(Panel_Event) do
            local fire_combine_event_name = combine_panel_event_name(event_name, panel_data.panel_name)
            local fire_event_name = event_name
            local event_closure = self._cached_forward_panel_event_closure[fire_combine_event_name]
            if not event_closure then
                event_closure = Functional.make_closure(self._forward_panel_events, self, fire_combine_event_name, fire_event_name)
                self._cached_forward_panel_event_closure[fire_combine_event_name] = event_closure
            end
            ev_name_fns[event_name] = event_closure
        end
        panel_data.event_bind_ids = self._event_binder:batch_bind(panel_data.panel, ev_name_fns)
    end
end

function UIPanelMgr:is_panel_enable(panel_name)
    local ret = false
    local panel_data = self:_get_cached_panel_data(panel_name)
    if panel_data then
        ---@type UIPanelBase
        local panel = panel_data.panel
        ret = panel:is_enable()
    end
    return ret
end







