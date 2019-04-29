
AvatarZoneServiceMsgHandler = AvatarZoneServiceMsgHandler or class("AvatarZoneServiceMsgHandler", ZoneServiceMsgHandlerbase)

function AvatarZoneServiceMsgHandler:ctor()
    AvatarZoneServiceMsgHandler.super.ctor(self)
end

function AvatarZoneServiceMsgHandler:init(...)
    AvatarZoneServiceMsgHandler.super.init(self, ...)
    self:set_handler_msg_fn(System_Pid.Test_5, Functional.make_closure(self.handle_Test_5, self))
    self:set_handler_msg_fn(System_Pid.Test_6, Functional.make_closure(self.handle_Test_6, self))
end

function AvatarZoneServiceMsgHandler:handle_Test_5(from_service, pid, msg)
    log_debug("reach AvatarZoneServiceMsgHandler:handle_Test_5")
    self:send(from_service, System_Pid.Test_6, {})
end

function AvatarZoneServiceMsgHandler:handle_Test_6(from_service, pid, msg)
    log_debug("reach AvatarZoneServiceMsgHandler:handle_Test_6")
end
