
UIPanelWrapper = UIPanelWrapper or class("UIPanelWrapper", UIPanelInterface)

function UIPanelWrapper:ctor(panel_mgr, panel_setting)
    self.panel_mgr = panel_mgr
    self.panel_setting = panel_setting
    assert(self.panel_setting)
    self.panel_state = UI_Panel_State.free
    self.want_panel_state = UI_Panel_State.free
    self.res_loader = CS.Lua.LuaResLoaderProxy.Create()
    self.event_mgr = EventMgr:new()
    self.timer_proxy = TimerProxy:new()
    self.wrapper_root_go = nil
    self.panel_root_go = nil
    self.want_show_panel_data = nil
    self.is_new_show = true
    self.is_freezed = true
    self.panel = nil
end

function UIPanelWrapper:init()

end





