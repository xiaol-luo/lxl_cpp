
ZoneServiceRpcMgr = ZoneServiceRpcMgr or class("ZoneServiceRpcMgr", RpcMgrBase)

function ZoneServiceRpcMgr:ctor()
    self.super:ctor()
    self.msg_handler = nil
end

function ZoneServiceRpcMgr:init(zs_msg_handler)
    self.super:init()
    self.msg_handler = zs_msg_handler
    local handle_fn =  function(from_service, pid, msg)
        self:on_msg(from_service, pid, msg)
    end
    self.msg_handler:set_handler_msg_fn(System_Pid.Zone_Service_Rpc_Rsp, handle_fn)
    self.msg_handler:set_handler_msg_fn(System_Pid.Zone_Service_Rpc_Req, handle_fn)

    -- for test
    self.rsp_process_fn["hello_world"] = function(rsp, ...)
        local params = {...}
        local param_size = select('#', ...)
        -- self:respone(rsp.id, rsp.from_host, rsp.from_id, Rpc_Const.Action_Return_Result, ...)
        local co = coroutine.create(function(rsp, ...)
            log_debug("aaaaaaaaaaaaaaaaaaaaaaaaaaa 2")
            local st, p1, p2 = ServiceMain.avatar_rpc_client:simple_rsp("p1", "p2")
            log_debug("in process fn hello world 1 %s %s %s", st, p1, p2)
            st, p1, p2 = ServiceMain.avatar_rpc_client:simple_rsp("p3", "p4")
            log_debug("in process fn hello world 2 %s %s %s", st, p1, p2)

            rsp:add_delay_execute(function ()
                ServiceMain.avatar_rpc_client:call(nil, "simple_rsp", 1, 2, 3)
            end)
            rsp:respone(...)
        end)
        rsp.hold_co = co
        log_debug("aaaaaaaaaaaaaaaaaaaaaaaaaaa 1")
        coroutine.resume(co, rsp, ...)
        log_debug("aaaaaaaaaaaaaaaaaaaaaaaaaaa 3")
    end

    self.rsp_process_fn["simple_rsp"] = function(rsp, ...)
        self:respone(rsp.id, rsp.from_host, rsp.from_id, Rpc_Const.Action_Return_Result, ...)
    end
end

function ZoneServiceRpcMgr:destory()
    self.super:destory()
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

