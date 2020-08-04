
---@class RpcServiceProxy
RpcServiceProxy = RpcServiceProxy or class("RpcServiceProxy")

function RpcServiceProxy:ctor(rpc_svc)
    ---@type RpcService
    self._rpc_svc = rpc_svc
    self._set_remote_call_record = {}
end


---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcServiceProxy:set_remote_call_handle_fn(fn_name, fn)
    if fn then
        assert(not self._set_remote_call_record[fn_name])
    end
    self._rpc_svc:set_remote_call_handle_fn(fn_name, fn)
    self._set_remote_call_record[fn_name] = fn and true or nil
end

---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcServiceProxy:set_remote_call_coro_handle_fn(fn_name, fn)
    if fn then
        assert(not self._set_remote_call_record[fn_name])
    else
        assert(self._set_remote_call_record[fn_name])
    end
    self._rpc_svc:set_remote_call_coro_handle_fn(fn_name, fn)
    self._set_remote_call_record[fn_name] = fn and true or nil
end

function RpcServiceProxy:clear_remote_call()
    for fn_name, _ in pairs(self._set_remote_call_record) do
        self._rpc_svc:set_remote_call_coro_handle_fn(fn_name, nil)
    end
    self._set_remote_call_record = {}
end

---@param cb_fn Fn_RpcRemoteCallCallback
function RpcServiceProxy:call(cb_fn, remote_server_key, remote_fn, ...)
    self._rpc_svc:call(cb_fn, remote_server_key, remote_fn, ...)
end

---@return RpcClient
function RpcServiceProxy:create_client(remote_server_key)
    local ret = self._rpc_svc:create_client(remote_server_key)
    return ret
end

---@return RpcClient
function RpcServiceProxy:create_random_client(server_role)
    local ret = self._rpc_svc:create_random_client(server_role)
    return ret
end
