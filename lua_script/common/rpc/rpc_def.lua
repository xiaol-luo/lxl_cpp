
Last_Rpc_Unique_Id = Last_Rpc_Unique_Id or 0

function NextRpcUniqueId()
    Last_Rpc_Unique_Id = Last_Rpc_Unique_Id + 1
    return Last_Rpc_Unique_Id
end

Rpc_Const =
{
    Action_Return_Result = "Action_Return_Result",
    Action_PostPone_Expire = "Action_PostPone_Expire",
    Default_Expire_Ms = 30000,
}

Rpc_Error =
{
    None = "None",
    Wait_Expired = "Wait_Expired",

}