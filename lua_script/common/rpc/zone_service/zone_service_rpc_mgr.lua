
ZoneServiceRpcMgr = ZoneServiceRpcMgr or class("ZoneServiceRpcMgr", RpcMgrBase)

function ZoneServiceRpcMgr:ctor()
    ZoneServiceRpcMgr.super.ctor(self)
    self.msg_handler = nil
end

function ZoneServiceRpcMgr:init(zs_msg_handler)
    ZoneServiceRpcMgr.super.init(self)
    self.msg_handler = zs_msg_handler
    local handle_fn =  function(from_service, pid, msg)
        self:on_msg(from_service, pid, msg)
    end
    self.msg_handler:set_handler_msg_fn(System_Pid.Zone_Service_Rpc_Rsp, handle_fn)
    self.msg_handler:set_handler_msg_fn(System_Pid.Zone_Service_Rpc_Req, handle_fn)
end

function ZoneServiceRpcMgr:destory()
    ZoneServiceRpcMgr.super.destory(self)
    if self.msg_handler then
        self.msg_handler:set_handler_msg_fn(System_Pid.Zone_Service_Rpc_Rsp, nil)
    end
end

function ZoneServiceRpcMgr:on_msg(from_host, pid, block, ...)
    local handle_fn = nil
    if System_Pid.Zone_Service_Rpc_Req == pid then
        handle_fn = self.handle_req_msg
    end
    if System_Pid.Zone_Service_Rpc_Rsp == pid then
        handle_fn = self.handle_rsp_msg
    end
    if handle_fn then
        handle_fn(self, from_host, pid, block)
    end
end

function ZoneServiceRpcMgr:net_call(req_id, remote_host, remote_fn, ...)
    -- log_debug("ZoneServiceRpcMgr:net_call %s", {...})
    local ret = Rpc_Error.Unknown
    if self.msg_handler then
        local msg = {}
        msg.id = req_id
        msg.fn_name = remote_fn
        msg.fn_params = self:pack_params(...)
        if self.msg_handler:send(remote_host, System_Pid.Zone_Service_Rpc_Req, msg) then
           ret = Rpc_Error.None
        end
    end
    return ret
end

function ZoneServiceRpcMgr:net_response(remote_host, req_id, action, ...)
    -- log_debug("ZoneServiceRpcMgr:net_response %s", {...})
    local ret = Rpc_Error.Unknown
    if self.msg_handler then
        local msg = {}
        msg.req_id = req_id
        msg.action = action
        msg.action_params = self:pack_params(...)
        if self.msg_handler:send(remote_host, System_Pid.Zone_Service_Rpc_Rsp, msg) then
            ret = Rpc_Error.None
        end
    end
    return ret
end

function ZoneServiceRpcMgr:pack_params(...)
    local tb = {}
    tb.len = select('#', ...)
    local params = {...}
    tb.params = {}
    for i=1, tb.len do
        tb.params[tostring(i)] = params[i]
    end
    local ret = rapidjson.encode(tb)
    -- log_debug("-- ZoneServiceRpcMgr:pack_params ret=%s, tb=%s", ret, tb)
    return ret
end

function ZoneServiceRpcMgr:unpack_params(param_block)
    local tb = rapidjson.decode(param_block or "{}") or {}
    tb.len = tb.len or 0
    tb.params = tb.params or {}
    local params = {}
    for i=1, tb.len do
        params[i] = tb.params[tostring(i)]
    end
    return table.unpack(params, 1, tb.len)
end

