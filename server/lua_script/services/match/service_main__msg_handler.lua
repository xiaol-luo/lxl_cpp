

function MatchService:_init_zone_net_msg_handler()
    self.msg_handler = ZoneServiceMsgHandlerbase:new()
    self.msg_handler:init()
end