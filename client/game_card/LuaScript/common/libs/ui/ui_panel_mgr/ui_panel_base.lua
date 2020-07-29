
---@class UIPanelBase:UIPanelInterface
UIPanelBase = UIPanelBase or class("UIPanelBase", UIPanelInterface)

function UIPanelBase:ctor(panel_wrapper, panel_setting, root_go)
    UIPanelBase.super.ctor(self)
    self.panel_wrapper = panel_wrapper
    self.panel_setting = panel_setting
    self.root_go = root_go
    self.panel_mgr = self.panel_wrapper.panel_mgr
    self._internal_event_mgr = self.panel_wrapper._internal_event_mgr
end

function UIPanelBase:init()

end

function UIPanelBase:show(panel_data)
    if not self:is_ready() then
        return
    end
    if self:get_state() == UI_Panel_State.showed then
        return
    end
    self._internal_event_mgr:fire(UI_Panel_Event.pre_show, self, panel_data)
    self:on_show(true, panel_data)
    self._internal_event_mgr:fire(UI_Panel_Event.show, self, panel_data)
end

function UIPanelBase:reshow()
    if not self:is_ready() then
        return
    end
    if self:get_state() == UI_Panel_State.showed then
        return
    end
    self._internal_event_mgr:fire(UI_Panel_Event.pre_reshow, self)
    self:on_show(false, nil)
    self._internal_event_mgr:fire(UI_Panel_Event.reshow, self)
end

function UIPanelBase:hide()
    if not self:is_ready() then
        return
    end
    if self:get_state() == UI_Panel_State.hided then
        return
    end
    self._internal_event_mgr:fire(UI_Panel_Event.pre_hide, self)
    self:on_hide()
    self._internal_event_mgr:fire(UI_Panel_Event.hide, self)
end

function UIPanelBase:release()
    if not self:is_ready() or self:is_released() then
        return
    end
    self:hide()
    self._internal_event_mgr:fire(UI_Panel_Event.pre_release, self)
    self:on_release()
    self._internal_event_mgr:fire(UI_Panel_Event.release, self)
end

function UIPanelBase:get_setting()
    return self.panel_setting
end

function UIPanelBase:get_panel_name()
    return self.panel_setting.panel_name
end

function UIPanelBase:get_state()
    return self.panel_wrapper:get_state()
end

function UIPanelBase:is_loading()
    return false
end

function UIPanelBase:is_ready()
    return self.panel_wrapper:is_ready()
end

function UIPanelBase:is_released()
    return self.panel_wrapper:is_released()
end

function UIPanelBase:get_root()
    return self.root_go
end

function UIPanelBase:on_show(is_new_show, panel_data)
    -- log_debug("UIPanelBase:on_show")
end

function UIPanelBase:on_hide()
    -- log_debug("UIPanelBase:on_hide")
end

function UIPanelBase:on_release()
    -- log_debug("UIPanelBase:on_release")
end



