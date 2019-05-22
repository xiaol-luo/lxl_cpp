
LoginZoneServiceMsgHandler = LoginZoneServiceMsgHandler or class("LoginZoneServiceMsgHandler", ZoneServiceMsgHandlerbase)

function LoginZoneServiceMsgHandler:ctor()
    LoginZoneServiceMsgHandler.super.ctor(self)
end

function LoginZoneServiceMsgHandler:init(...)
    LoginZoneServiceMsgHandler.super.init(self, ...)
end
