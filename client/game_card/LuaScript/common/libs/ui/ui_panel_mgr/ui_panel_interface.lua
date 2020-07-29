
---@class UIPanelInterface:EventMgr
UIPanelInterface = UIPanelInterface or class("UIPanelInterface", EventMgr)

function UIPanelInterface:ctor()
    UIPanelInterface.super.ctor(self)
    ---@type EventBinder
    self._event_binder = EventBinder:new()
end

function UIPanelInterface:init()

end

function UIPanelInterface:show(panel_data)

end

function UIPanelInterface:reshow()

end

function UIPanelInterface:hide()

end

function UIPanelInterface:release()
    self._event_binder:release_all()
end

function UIPanelInterface:get_setting()

end

function UIPanelInterface:get_panel_name()

end

function UIPanelInterface:get_state()

end

function UIPanelInterface:is_loading()

end

function UIPanelInterface:is_ready()

end

function UIPanelInterface:is_released()

end

function UIPanelInterface:get_root()

end


