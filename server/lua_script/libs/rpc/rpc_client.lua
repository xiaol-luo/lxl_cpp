
---@class RpcClient
RpcClient = RpcClient or class("RpcClient")

local mt = getmetatable(RpcClient)
mt.__index = function(ins, key)
    -- 用这种方式来构造远程调用函数，所以RpcClient不要随便乱用
    if not is_string(key) then
        return nil
    end
    local ret = function(ins, ...)
        return RpcClient.coro_call(ins, key, ...)
    end
    ins[key] = ret
    return ret
end

function RpcClient:ctor(rpc_mgr, remote_host)
    self.rpc_mgr = rpc_mgr
    self.remote_host = remote_host
end

function RpcClient:setup_coroutine_fns(fn_names)
    for _, fn_name in pairs(fn_names) do
        if is_string(fn_name) and #fn_name > 0 then
            assert(not self[fn_names], string.format("can not change attribute already exist %s", fn_name))
            self[fn_name] = function(self, ...)
                return self:coro_call(fn_name, ...)
            end
        end
    end
end

---@param cb_fn Fn_RpcRemoteCallCallback
function RpcClient:call(cb_fn, remote_fn, ...)
    -- log_debug("RpcClient:call %s %s %s", cb_fn, remote_fn, {...})
    self.rpc_mgr:call(cb_fn, self.remote_host, remote_fn, ...)
end

---@param cb_fn Fn_RpcRemoteCallCallback
function RpcClient:coro_call(remote_fn, ...)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    -- log_debug("RpcClient:coro_call fn_name:%s", remote_fn)
    self:call(new_coroutine_callback(co), remote_fn, ...)
    return ex_coroutine_yield(co)
end

function create_rpc_client(rpc_mgr, ...)
    local n, args = Functional.varlen_param_info(...)
    assert(n == 1 or n == 3, "input param should 1 or 3")
    local etcd_key = args[1]
    if 3 == n then
        local zone = string.lrtrim(args[1], "/")
        local service = string.lrtrim(args[2], "/")
        local idx = string.lrtrim(tostring(args[3]), "/")
        etcd_key = path.combine("/", zone, service, idx)
    end
    local ret = RpcClient:new(rpc_mgr, etcd_key)
    return ret
end