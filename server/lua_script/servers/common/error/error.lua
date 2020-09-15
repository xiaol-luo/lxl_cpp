
---@class Error
---@field fight Error_Fight
Error = {}

Error_None = 0
Error_Exist = -1
Error_Unknown = -2

--[[
Rpc_Error =
{
    None = 0,
    Unknown = -301,
    Wait_Expired = -302,
    Remote_Host_Error = -303,
    To_Host_Not_Reachable = -304,
    From_Host_Not_Reachable = -305,
}
]]

Error_Consistent_Hash_Mismatch = -400
Error_Consistent_Hash_Adjusting = -401
Error_Server_Role_Shadow_Parted = -402
Error_Not_Available_Server = -403

Error_Mongo_Opera_Fail = -500

Error_Not_Find_Role = -510

require("servers.common.error.error_world_server")
require("servers.common.error.error_game_server")
require("servers.common.error.error_fight")

function pick_error_num(...)
    local ret = Error_None
    for _, v in pairs({...}) do
        if Error_None ~= v then
            ret = v
            break
        end
    end
    return ret
end