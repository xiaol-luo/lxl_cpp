
UIPanelWrapper = UIPanelWrapper or class("UIPanelWrapper", UIPanelInterface)

function UIPanelWrapper:ctor(panel_mgr, panel_setting)
    self.panel_mgr = panel_mgr
    self.panel_setting = panel_setting
    assert(self.panel_setting)
    self.panel_state = UI_Panel_State.free
    self.want_panel_state = UI_Panel_State.free
    self.res_loader = CS.Lua.LuaResLoaderProxy.Create()
    self.event_mgr = EventMgr:new()
    self.wrapper_event_mgr = EventMgr:new()
    self.wrapper_event_subcriber = self.wrapper_event_mgr:create_subscriber()
    self.timer_proxy = TimerProxy:new()
    self.wrapper_root_go = nil
    self.ui_root_go = nil
    self.panel_parent_go = nil
    self.panel_root_go = nil
    self.panel_logic = nil
    self.want_show_panel_data = nil
    self.is_new_show = true
    self.is_freezed = true
end

function UIPanelWrapper:init()
    self.wrapper_root_go = self.panel_mgr.panel_wrapper_res_obs:Instantiate()
    self.wrapper_root_go.name = string.format("%s_wrapper", self.panel_setting.panel_name)
    self.ui_root_go = UIHelp.find_gameobject(self.wrapper_root_go, "Root")
    self.panel_parent_go = UIHelp.find_gameobject(self.wrapper_root_go, "Root/PanelRoot")
    assert(self.wrapper_root_go)
    local parent_layer = self.panel_mgr.layers[self.panel_setting.belong_layer]
    assert(parent_layer)
    self.wrapper_root_go.transform:SetParent(parent_layer, false)
    self.wrapper_root_go:SetActive(true)
    self.wrapper_root_go.transform.localScale = CS.UnityEngine.Vector3.one
    self.wrapper_root_go.transform.localPosition = CS.UnityEngine.Vector3.zero

    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.pre_showed, Functional.make_closure(self._on_event_panel_pre_show, self))
    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.showed, Functional.make_closure(self._on_event_panel_showed, self))
    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.pre_reshow, Functional.make_closure(self._on_event_panel_pre_reshow, self))
    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.reshowed, Functional.make_closure(self._on_event_panel_reshowd, self))
    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.pre_hide, Functional.make_closure(self._on_event_panel_pre_hide, self))
    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.hided, Functional.make_closure(self._on_event_panel_hided, self))
    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.pre_release, Functional.make_closure(self._on_event_panel_pre_release, self))
    self.wrapper_event_subcriber:subscribe(UI_Panel_Event.released, Functional.make_closure(self._on_event_panel_released, self))

end

function UIPanelWrapper:get_root()
    return self.wrapper_root_go
end

function UIPanelWrapper:_check_load_panel()
    if UI_Panel_State.free ~= self.panel_state then
        return
    end
    self.panel_state = UI_Panel_State.loading
    self.res_loader:AsyncLoadAsset(self.panel_setting.res_path, function(res_path, res_obs)
        if self:is_released() then
            return
        end
        if not res_obs.isValid then
            log_assert(false, "panel %s load resource faile, path is %s", self.panel_setting.panel_name, res_path)
        end
        self.panel_state = UI_Panel_State.loaded
        self.panel_root_go = res_obs:Instantiate()
        self.panel_root_go.transform:SetParent(self.panel_parent_go.transform, false)
        self.panel_root_go:SetActive(true)
        self.panel_root_go.transform.localScale = CS.UnityEngine.Vector3.one
        self.panel_root_go.transform.localPosition = CS.UnityEngine.Vector3.zero
        self.panel_root_go.name = self.panel_setting.panel_name
        self.panel_logic = self.panel_setting.panel_logic:new(self, self.panel_setting, self.panel_root_go)
        self.panel_logic:init()
        if UI_Panel_State.showed == self.want_panel_state then
            self:show(self.want_show_panel_data)
        end
        if UI_Panel_State.hided == self.want_panel_state then
            -- self:show(self.want_show_panel_data)
            self:hide()
        end
    end)
end

function UIPanelWrapper:is_loading()
    local ret = UI_Panel_State.loading == self.panel_state
    return ret
end

function UIPanelWrapper:is_released()
    local ret = UI_Panel_State.released == self.panel_state
    return ret
end

function UIPanelWrapper:is_ready()
    local ret = true
    if UI_Panel_State.free == self.panel_state then
        ret = false
    end
    if self:is_loading() then
        ret = false
    end
    if self:is_released() then
        ret = false
    end
    return ret
end

function UIPanelWrapper:get_panel_name()
    return self.panel_setting.panel_name
end

function UIPanelWrapper:get_panel_setting()
    return self.panel_setting
end

function UIPanelWrapper:get_panel_logic()
    return self.panel_logic
end

function UIPanelWrapper:get_panel_state()
    return self.panel_state
end

function UIPanelWrapper:show(panel_data)
    if self:is_released() then
        return
    end
    self:_check_load_panel()
    if self:is_ready() then
        self.panel_logic:show(panel_data)
    else -- loading
        self.wrapper_event_mgr:fire(UI_Panel_Event.pre_showed, nil, panel_data)
        self.wrapper_event_mgr:fire(UI_Panel_Event.showed, nil, panel_data)
    end
end

function UIPanelWrapper:reshow()
    if self:is_released() then
        return
    end
    if UI_Panel_State.showed == self.panel_state then
        return
    end
    self:_check_load_panel()
    if self:is_ready() and self.is_new_show then
        self.panel_logic:show(self.want_show_panel_data)
    else -- loading
        if self:is_ready() then
            self.panel_logic:reshow()
        else
            self.wrapper_event_mgr:fire(UI_Panel_Event.pre_reshow, nil)
            self.wrapper_event_mgr:fire(UI_Panel_Event.reshowed, nil)
        end
    end
end

function UIPanelWrapper:hide()
    if self:is_released() then
        return
    end
    if UI_Panel_State.hided == self.panel_state then
        return
    end
    self:_check_load_panel()
    if self:is_ready() then
        self.panel_logic:hide()
    else
        self.wrapper_event_mgr:fire(UI_Panel_Event.pre_hide, nil)
        self.wrapper_event_mgr:fire(UI_Panel_Event.hided, nil)
    end
end

function UIPanelWrapper:release()
    if self:is_released() then
        return
    end
    self:hide()
    if self:is_ready() then
        self.panel_logic:release()
    else
        self.wrapper_event_mgr:fire(UI_Panel_Event.pre_release, nil)
        self.wrapper_event_mgr:fire(UI_Panel_Event.released, nil)
    end
end

function UIPanelWrapper:_on_event_panel_pre_show(panel_logic, panel_data)
    self.ui_root_go:SetActive(true)

    if panel_logic then
        self.is_new_show = false
        self.want_show_panel_data = nil
        self.event_mgr:fire(UI_Panel_Event.pre_showed, panel_logic, panel_data)
    else
        self.is_new_show = true
        self.want_show_panel_data = panel_data
    end
end

function UIPanelWrapper:_on_event_panel_showed(panel_logic, panel_data)
    if panel_logic then
        self.panel_state = UI_Panel_State.showed
        self.event_mgr:fire(UI_Panel_Event.showed, panel_logic, panel_data)
    else
        self.want_panel_state = UI_Panel_State.showed
    end
end

function UIPanelWrapper:_on_event_panel_pre_reshow(panel_logic)
    if panel_logic then
        if self.is_new_show then
            self:show(self.want_show_panel_data)
        else
            self.ui_root_go:SetActive(true)
            self.event_mgr:fire(UI_Panel_Event.pre_reshow, panel_logic)
        end
    else
        self.ui_root_go:SetActive(true)
    end
end

function UIPanelWrapper:_on_event_panel_reshowd(panel_logic)
    if panel_logic then
        self.panel_state = UI_Panel_State.showed
        self.event_mgr:fire(UI_Panel_Event.reshowed, panel_logic)
    else
        self.want_panel_state = UI_Panel_State.showed
    end
end

function UIPanelWrapper:_on_event_panel_pre_hide(panel_logic)
    if panel_logic then
        self.event_mgr:fire(UI_Panel_Event.pre_hide, panel_logic)
    end
end

function UIPanelWrapper:_on_event_panel_hided(panel_logic)
    if panel_logic then
        self.panel_state = UI_Panel_State.hided
        self.event_mgr:fire(UI_Panel_Event.hided, panel_logic)
    else
        self.want_panel_state = UI_Panel_State.hided
    end
    self.ui_root_go:SetActive(false)
end

function UIPanelWrapper:_on_event_panel_pre_release(panel_logic)
    self.event_mgr:fire(UI_Panel_Event.pre_release, panel_logic)
end

function UIPanelWrapper:_on_event_panel_released(panel_logic)
    self.panel_state = UI_Panel_State.released
    self.event_mgr:fire(UI_Panel_Event.released, panel_logic)
    self.wrapper_root_go.transform:SetParent(nil)
    self.res_loader:Release()
    self.timer_proxy:release_all()
    self.wrapper_event_subcriber:release_all()
    self.wrapper_event_mgr:cancel_all()
    self.event_mgr:cancel_all()
    CS.UnityEngine.GameObject.Destroy(self.wrapper_root_go)
end

function UIPanelWrapper:get_event_mgr()
    return self.event_mgr
end
