
RpcClient = RpcClient or class("RpcClient")

function RpcClient:ctor(rpc_mgr, remote_host)
    self.rpc_mgr = rpc_mgr
    self.remote_host = remote_host

    -- TODO: 优化：可改为用时创建
    local fn_names = table.keys(self.rpc_mgr.req_msg_process_fn)
    self:setup_coroutine_fns(fn_names)
end

function RpcClient:setup_coroutine_fns(fn_names)
    for _, fn_name in pairs(fn_names) do
        if IsString(fn_name) and #fn_name > 0 then
            assert(not self[fn_names], string.format("can not change attribute already exist %s", fn_name))
            self[fn_name] = function(self, ...)
                return self:_co_call(fn_name, ...)
            end
        end
    end
end

function RpcClient:call(cb_fn, remote_fn, ...)
    -- log_debug("RpcClient:call %s %s %s", cb_fn, remote_fn, {...})
    self.rpc_mgr:call(cb_fn, self.remote_host, remote_fn, ...)
end

function RpcClient:_co_call_cb(co, rpc_err, ...)
    -- log_debug("RpcClient:_co_call _co_call_cb %s %s", co, rpc_err)
    coroutine_resume(co, rpc_err, ...)
end

function RpcClient:_co_call(remote_fn, ...)
    local co = coroutine.running()
    assert(co, "should be called in a running coroutine")
    -- log_debug("RpcClient:_co_call fn_name:%s", remote_fn)
    local cb_fn = Functional.make_closure(self._co_call_cb, self, co)
    self:call(cb_fn, remote_fn, ...)
    return coroutine_yield()
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