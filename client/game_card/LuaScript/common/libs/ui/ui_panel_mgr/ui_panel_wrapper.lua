---@class UIPanelWrapper:UIPanelInterface
UIPanelWrapper = UIPanelWrapper or class("UIPanelWrapper", UIPanelInterface)

function UIPanelWrapper:ctor(panel_mgr, panel_setting)
    UIPanelWrapper.super.ctor(self)
    self.panel_mgr = panel_mgr
    self.panel_setting = panel_setting
    assert(self.panel_setting)
    self.panel_state = UI_Panel_State.free
    self.want_panel_state = UI_Panel_State.free
    self.res_loader = CS.Lua.LuaResLoaderProxy.Create()
    self._internal_event_mgr = EventMgr:new()
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

    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.pre_show, Functional.make_closure(self._on_event_panel_pre_show, self))
    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.show, Functional.make_closure(self._on_event_panel_show, self))
    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.pre_reshow, Functional.make_closure(self._on_event_panel_pre_reshow, self))
    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.reshow, Functional.make_closure(self._on_event_panel_reshow, self))
    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.pre_hide, Functional.make_closure(self._on_event_panel_pre_hide, self))
    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.hide, Functional.make_closure(self._on_event_panel_hide, self))
    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.pre_release, Functional.make_closure(self._on_event_panel_pre_release, self))
    self._event_binder:bind(self._internal_event_mgr, UI_Panel_Event.release, Functional.make_closure(self._on_event_panel_release, self))
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
        self._internal_event_mgr:fire(UI_Panel_Event.pre_show, nil, panel_data)
        self._internal_event_mgr:fire(UI_Panel_Event.show, nil, panel_data)
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
            self._internal_event_mgr:fire(UI_Panel_Event.pre_reshow, nil)
            self._internal_event_mgr:fire(UI_Panel_Event.reshow, nil)
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
        self._internal_event_mgr:fire(UI_Panel_Event.pre_hide, nil)
        self._internal_event_mgr:fire(UI_Panel_Event.hide, nil)
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
        self._internal_event_mgr:fire(UI_Panel_Event.pre_release, nil)
        self._internal_event_mgr:fire(UI_Panel_Event.release, nil)
    end
end

function UIPanelWrapper:_on_event_panel_pre_show(panel_logic, panel_data)
    self.ui_root_go:SetActive(true)

    if panel_logic then
        self.is_new_show = false
        self.want_show_panel_data = nil
        self:fire(UI_Panel_Event.pre_show, panel_logic, panel_data)
    else
        self.is_new_show = true
        self.want_show_panel_data = panel_data
    end
end

function UIPanelWrapper:_on_event_panel_show(panel_logic, panel_data)
    if panel_logic then
        self.panel_state = UI_Panel_State.showed
        self:fire(UI_Panel_Event.show, panel_logic, panel_data)
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
            self:fire(UI_Panel_Event.pre_reshow, panel_logic)
        end
    else
        self.ui_root_go:SetActive(true)
    end
end

function UIPanelWrapper:_on_event_panel_reshow(panel_logic)
    if panel_logic then
        self.panel_state = UI_Panel_State.showed
        self:fire(UI_Panel_Event.reshow, panel_logic)
    else
        self.want_panel_state = UI_Panel_State.showed
    end
end

function UIPanelWrapper:_on_event_panel_pre_hide(panel_logic)
    if panel_logic then
        self:fire(UI_Panel_Event.pre_hide, panel_logic)
    end
end

function UIPanelWrapper:_on_event_panel_hide(panel_logic)
    if panel_logic then
        self.panel_state = UI_Panel_State.hided
        self:fire(UI_Panel_Event.hide, panel_logic)
    else
        self.want_panel_state = UI_Panel_State.hided
    end
    self.ui_root_go:SetActive(false)
end

function UIPanelWrapper:_on_event_panel_pre_release(panel_logic)
    self:fire(UI_Panel_Event.pre_release, panel_logic)
end

function UIPanelWrapper:_on_event_panel_release(panel_logic)
    self.panel_state = UI_Panel_State.released
    self:fire(UI_Panel_Event.release, panel_logic)
    self.wrapper_root_go.transform:SetParent(nil)
    self.res_loader:Release()
    self.timer_proxy:release_all()
    self._internal_event_mgr:cancel_all()
    self:cancel_all()
    CS.UnityEngine.GameObject.Destroy(self.wrapper_root_go)
end
