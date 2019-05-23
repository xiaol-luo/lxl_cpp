
GameZoneServiceMsgHandler = GameZoneServiceMsgHandler or class("GameZoneServiceMsgHandler", ZoneServiceMsgHandlerbase)

function GameZoneServiceMsgHandler:ctor()
    GameZoneServiceMsgHandler.super.ctor(self)
end

function GameZoneServiceMsgHandler:init(...)
    GameZoneServiceMsgHandler.super.init(self, ...)
end
