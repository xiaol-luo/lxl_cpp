
GateZoneServiceMsgHandler = GateZoneServiceMsgHandler or class("GateZoneServiceMsgHandler", ZoneServiceMsgHandlerbase)

function GateZoneServiceMsgHandler:ctor()
    GateZoneServiceMsgHandler.super.ctor(self)
end

function GateZoneServiceMsgHandler:init(...)
    GateZoneServiceMsgHandler.super.init(self, ...)
end
