
function LoginService:new_zone_net_msg_handler()
    local msg_handler = LoginZoneServiceMsgHandler:new()
    msg_handler:init()
    return msg_handler
end