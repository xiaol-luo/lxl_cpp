
---@class RpcServiceRpcMgr
RpcServiceRpcMgr = RpcServiceRpcMgr or class("RpcServiceRpcMgr", RpcMgrBase)

function RpcServiceRpcMgr:ctor(rpc_service)
    RpcServiceRpcMgr.super.ctor(self)
    self._rpc_service = rpc_service
    ---@type PeerNetService
    self._peer_net = self._rpc_service.server.peer_net
    self.msg_handler = nil
end

function RpcServiceRpcMgr:_send_msg(remote_server_key, pid, msg)
    local ret = self._peer_net:send_msg(remote_server_key, pid, msg)
    return ret
end

function RpcServiceRpcMgr:_register_pto_handle_fn(pid, fn)
    self._peer_net:set_pto_handle_fn(pid, fn)
end

function RpcServiceRpcMgr:init()
    RpcServiceRpcMgr.super.init(self)
    self:_register_pto_handle_fn(Rpc_Pid.req_remote_call, Functional.make_closure(self._on_msg_adapter, self))
    self:_register_pto_handle_fn(Rpc_Pid.rsp_remote_call, Functional.make_closure(self._on_msg_adapter, self))
end

function RpcServiceRpcMgr:destory()
    RpcServiceRpcMgr.super.destory(self)
    self:_register_pto_handle_fn(Rpc_Pid.req_remote_call, nil)
    self:_register_pto_handle_fn(Rpc_Pid.rsp_remote_call, nil)

end

function RpcServiceRpcMgr:_on_msg_adapter(pid, msg, cnn_unique_id, from_server_key, from_server_id)
    self:on_msg(from_server_key, pid, msg)
end

function RpcServiceRpcMgr:on_msg(from_host, pid, msg, ...)
    local handle_fn = nil
    if Rpc_Pid.req_remote_call == pid then
        handle_fn = self.handle_req_msg
    end
    if Rpc_Pid.rsp_remote_call == pid then
        handle_fn = self.handle_rsp_msg
    end
    if handle_fn then
        handle_fn(self, from_host, pid, msg)
    end
end

function RpcServiceRpcMgr:net_call(req_id, remote_host, remote_fn, ...)
    local ret = Rpc_Error.Unknown
    local msg = {}
    msg.req_id = req_id
    msg.fn_name = remote_fn
    msg.fn_params = self:pack_params(...)
    if self:_send_msg(remote_host, Rpc_Pid.req_remote_call, msg) then
        ret = Rpc_Error.None
    else
        ret = Rpc_Error.To_Host_Not_Reachable
    end
    return ret
end

function RpcServiceRpcMgr:net_response(remote_host, req_id, action, ...)
    local ret = Rpc_Error.Unknown
    local msg = {}
    msg.req_id = req_id
    msg.action = action
    msg.action_params = self:pack_params(...)
    if self:_send_msg(remote_host, Rpc_Pid.rsp_remote_call, msg) then
        ret = Rpc_Error.None
    else
        ret = Rpc_Error.From_Host_Not_Reachable
    end
    return ret
end

function RpcServiceRpcMgr:pack_params(...)
    local tb = {}
    tb.len = select('#', ...)
    local params = {...}
    tb.params = {}
    for i=1, tb.len do
        tb.params[tostring(i)] = params[i]
    end
    local ret, error_msg = msgpack.encode_one(tb)
    assert(nil ~= ret, string.format("RpcServiceRpcMgr:pack_params fail error_msg:%s", error_msg))
    return ret
end

function RpcServiceRpcMgr:unpack_params(param_block)
    local tb, error_msg = msgpack.decode_one(param_block or "{}")
    assert(nil ~= tb, string.format("RpcServiceRpcMgr:unpack_params fail error_msg:%s", error_msg))
    tb.len = tb.len or 0
    tb.params = tb.params or {}
    local params = {}
    for i=1, tb.len do
        params[i] = tb.params[tostring(i)]
    end
    return table.unpack(params, 1, tb.len)
end
