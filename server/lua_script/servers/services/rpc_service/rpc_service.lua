
---@class RpcService: ServiceBase
RpcService = RpcService or class("RpcService", ServiceBase)

function RpcService:ctor(service_mgr, service_name)
    RpcService.super.ctor(self, service_mgr, service_name)
    self._next_unique_id = make_sequence(0)
    ---@type ProtoParser
    self._pto_parser = self.server.pto_parser
    ---@type RpcServiceRpcMgr
    self._rpc_mgr = RpcServiceRpcMgr:new(self)
end

function RpcService:_on_init()
    RpcService.super._on_init(self)
    self._pto_parser:load_files(Rpc_Pto.pto_files)
    self._pto_parser:setup_id_to_protos(Rpc_Pto.id_to_pto)
    self._rpc_mgr:init()

    -- for test
    --[[
    self:set_remote_call_handle_fn("hello", function(rpc_rsp, ...)
        log_print("handle remote call hello, params=", ...)
        rpc_rsp:respone(Error_None, "test", ...)
    end)
    ]]
end

function RpcService:_on_start()
    RpcService.super._on_start(self)
end

function RpcService:_on_stop()
    RpcService.super._on_stop(self)
end

function RpcService:_on_release()
    RpcService.super._on_release(self)
    self._rpc_mgr:destory()
end

function RpcService:_on_update()
    RpcService.super._on_update(self)
    self._rpc_mgr:on_frame()

    -- for test
    --[[
    local client = self:create_rpc_client(self.server:get_cluster_server_key())
    client:call(function (rpc_error_num, ...)
        -- log_print("remote call callback ", rpc_error_num, ...)
    end, "hello", "world")
    ]]
end

---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcService:set_remote_call_handle_fn(fn_name, fn)
    self._rpc_mgr:set_remote_call_handle_fn(fn_name, fn)
end

---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcService:set_remote_call_coro_handle_fn(fn_name, fn)
    self._rpc_mgr:set_remote_call_coro_handle_fn(fn_name, fn)
end

function RpcService:call(cb_fn, remote_server_key, remote_fn, ...)
    self._rpc_mgr(cb_fn, remote_server_key, remote_fn, ...)
end

---@return RpcClient
function RpcService:create_rpc_client(remote_server_key)
    local ret = RpcClient:new(self._rpc_mgr, remote_server_key)
    return ret
end
