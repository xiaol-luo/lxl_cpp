
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
    {
        [Proto_Const.Proto_Id]=ProtoId.req_user_login,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="ReqUserLogin"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.rsp_user_login,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="RspUserLogin"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.req_pull_role_digest,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="ReqPullRoleDigest"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.rsp_pull_role_digest,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="RspPullRoleDigest"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.req_create_role,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="ReqCreateRole"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.rsp_create_role,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="RspCreateRole"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.req_launch_role,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="ReqLaunchRole"
    },
    {
        [Proto_Const.Proto_Id]=ProtoId.rsp_launch_role,
        [Proto_Const.Proto_Type]=Proto_Const.Pb,
        [Proto_Const.Proto_Name]="RspLaunchRole"
    },
}


function get_game_pid_proto_map()
    return pid_proto_map
end