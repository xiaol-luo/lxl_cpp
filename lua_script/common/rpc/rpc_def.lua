
Last_Rpc_Unique_Id = Last_Rpc_Unique_Id or 0

function NextRpcUniqueId()
    Last_Rpc_Unique_Id = Last_Rpc_Unique_Id + 1
    return Last_Rpc_Unique_Id
end

Rpc_Const =
{
    Action_Return_Result = "Action_Return_Result",
    Action_PostPone_Expire = "Action_PostPone_Expire",
    Action_Report_Error = "Action_Report_Error",
    Default_Expire_Ms = 30000,
}

Rpc_Error =
{
    None = "None",
    Wait_Expired = "Wait_Expired",
    Remote_Host_Error = "Remote_Host_Error",
    Unknown = "Unknown",
}

local hold_varlen_ret = function(...)
    local n = select('#', ...)
    return n, {...}
end

function coroutine_resume(co, ...)
    local n, results = hold_varlen_ret(coroutine.resume(co, ...))
    local is_ok = results[1]
    if not is_ok then
        log_error("coroutine_resume fail reason:%s", results[2] or "unknown")
    end
    return table.unpack(results, 1, n)
end

function coroutine_yield(...)
    return coroutine.yield(...)
end