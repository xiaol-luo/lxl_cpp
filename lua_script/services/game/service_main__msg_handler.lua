
function GameService:new_zone_net_msg_handler()
    local msg_handler = GameZoneServiceMsgHandler:new()
    msg_handler:init()
    return msg_handler
end