
Panel_Event = Panel_Event or {}

Panel_Event.pre_open = "Panel_Event.pre_open"
Panel_Event.open = "Panel_Event.open"

Panel_Event.pre_enable = "Panel_Event.pre_enable"
Panel_Event.enable = "Panel_Event.enable"

Panel_Event.pre_disable = "Panel_Event.pre_disable"
Panel_Event.disable = "Panel_Event.disable"

Panel_Event.pre_release = "Panel_Event.pre_release"
Panel_Event.release = "Panel_Event.release"


function combine_panel_event_name(event_name, panel_name)
    assert(event_name)
    local ret = string.format("%s.%s", event_name, panel_name or "")
    return ret
end