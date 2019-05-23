
function GateService:new_zone_net_msg_handler()
    local msg_handler = GateZoneServiceMsgHandler:new()
    msg_handler:init()
    return msg_handler
end