
local pid_proto_map =
{
--[[
    {
        [Proto_Const.Proto_Id]=System_Pid.Zone_Service_Rpc_Req,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="RpcRequest"
    },
--]]

    {
        [Proto_Const.Proto_Id]=ProtoId.req_login_game,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="ReqLoginGame"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.rsp_login_game,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="RspLoginGame"
    },

}


function get_game_pid_proto_map()
    return pid_proto_map
end