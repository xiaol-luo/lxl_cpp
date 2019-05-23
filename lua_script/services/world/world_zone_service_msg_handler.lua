
WorldZoneServiceMsgHandler = WorldZoneServiceMsgHandler or class("WorldZoneServiceMsgHandler", ZoneServiceMsgHandlerbase)

function WorldZoneServiceMsgHandler:ctor()
    WorldZoneServiceMsgHandler.super.ctor(self)
end

function WorldZoneServiceMsgHandler:init(...)
    WorldZoneServiceMsgHandler.super.init(self, ...)
end
