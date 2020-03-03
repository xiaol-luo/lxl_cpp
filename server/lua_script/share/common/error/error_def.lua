Error = {}

Error_None = 0
Error_Exist = -1
Error_Unknown = -2

Error_Coro_Start = -100
Error_Coro_Logic = -101

Error_Http_State = -200

Rpc_Error =
{
    None = 0,
    Unknown = -301,
    Wait_Expired = -302,
    Remote_Host_Error = -303,
}

Error_Rpc_Unknown = Rpc_Error.Unknown -- -300
Error_Rpc_Expired = Rpc_Error.Wait_Expired -- -301
Error_Rpc_Remote_Host = Rpc_Error.Remote_Host_Error -- -302