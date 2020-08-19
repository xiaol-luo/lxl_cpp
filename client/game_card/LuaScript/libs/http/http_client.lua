
---@class UnityHttpClient
UnityHttpClient = UnityHttpClient or {}

---@alias Fn_UnityHttpRspCbFn fun(error:string, rspContent:string, heads_map:table):void


---@param rsp_fn Fn_UnityHttpRspCbFn
function UnityHttpClient.get(url, rsp_fn, heads_map, timeout_sec)
    return CS.Lua.HttpClient.Get(url, rsp_fn, heads_map or {}, timeout_sec or 30)
end

function UnityHttpClient.cancel(opera_id)
    CS.Lua.HttpClient.Cancel(opera_id)
end