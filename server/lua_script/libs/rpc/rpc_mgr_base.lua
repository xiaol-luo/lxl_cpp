

---@alias Fn_RpcRemoteCallHandleFn fun(rpc_rsp:RpcRsp, ...):void
---@alias Fn_RpcRemoteCallCallback fun(rpc_error_num:number, ...):void

---@class RpcMgrBase
RpcMgrBase = RpcMgrBase or class("RpcMgrBase")

function RpcMgrBase:ctor()
    self.req_list = {}
    self.last_check_expired_ms = 0
    self.Check_Expired_Span_ms = 3 * 1000
    self.rsp_list = {}
    ---@type table<string, Fn_RpcRemoteCallHandleFn>
    self.remote_call_handle_fn = {}
    self.delay_execute_fns = {}
    self._next_unique_id = make_sequence(0)
end

function RpcMgrBase:init()

end

function RpcMgrBase:destory()
    self.req_list = {}
end

function RpcMgrBase:on_msg(from_host, pid, msg, ...)
    assert(false, "should not reach here")
end

function RpcMgrBase:net_call(req_id, remote_host, remote_fn, ...)
    assert(false, "should not reach here")
    -- return Rpc_Error
end

function RpcMgrBase:net_response(remote_host, req_id, action, ...)
    assert(false, "should not reach here")
    -- return Rpc_Error
end

function RpcMgrBase:pack_params(...)
    assert(false, "should not reach here")
    -- return block
end

function RpcMgrBase:unpack_params(param_block)
    assert(false, "should not reach here")
    -- return ...
end

---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcMgrBase:set_remote_call_handle_fn(fn_name, fn)
    if not fn then
        self.remote_call_handle_fn[fn_name] = nil
        return
    end
    assert(not self.remote_call_handle_fn[fn_name])
    self.remote_call_handle_fn[fn_name] = fn
end

---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcMgrBase:set_remote_call_coro_handle_fn(fn_name, fn)
    if not fn then
        self.remote_call_handle_fn[fn_name] = nil
        return
    end

    assert(not self.remote_call_handle_fn[fn_name])

    local real_fn = function(rsp, ...)
        local co = ex_coroutine_create(function (rsp, ...)
            local co_fn = fn
            local n, rets = varlen_param_info(co_fn(rsp, ...))
            if n > 0 then
                rsp:send_back(table.unpack(rets, 1, n))
            end
        end, nil)
        rsp.co = co
        ex_coroutine_start(co, rsp, ...)
    end
    self.remote_call_handle_fn[fn_name] = real_fn
end

---@param cb_fn Fn_RpcRemoteCallCallback
function RpcMgrBase:call(cb_fn, remote_host, remote_fn, ...)
    assert(nil == cb_fn or is_function(cb_fn))
    assert(remote_host)
    assert(remote_fn)
    local req_id = self._next_unique_id()
    local err = self:net_call(req_id, remote_host, remote_fn, ...)
    if Rpc_Error.None ~= err then
        if cb_fn then -- 模拟异步
            table.insert(self.delay_execute_fns, function ()
                cb_fn(err)
            end)
        end
    else
        local req = RpcReq:new()
        req.id = req_id
        self.req_list[req.id] = req
        req.cb_fn = cb_fn
        req.expired_ms = native.logic_ms() + Rpc_Const.Default_Expire_Ms
        req.remote_host = remote_host
        req.remote_fn = remote_fn
    end
end

function RpcMgrBase:response(rsp_id, remote_host, req_id, action, ...)
    local rpc_rsp = self.rsp_list[rsp_id]
    if not rpc_rsp then
        return
    end
    local remove_rsp =false
    local err = self:net_response(remote_host, req_id, action, ...)
    if Rpc_Error.None ~= err then
        remove_rsp = true
    end
    if Rpc_Const.Action_Report_Error == action or Rpc_Const.Action_Return_Result then
        remove_rsp = true
    end
    if remove_rsp then
        self.rsp_list[rsp_id] = nil
        local delay_execute_fns = rpc_rsp.delay_execute_fns
        self.delay_execute_fns = {}
        for _, fn in ipairs(delay_execute_fns) do
            safe_call(fn)
        end
    end
end

function RpcMgrBase:handle_rsp_msg(from_host, pid, msg)
    -- msg contains req_id, action, action_params
    local req = self.req_list[msg.req_id]
    if not req then
        return
    end
    local action = msg.action
    if Rpc_Const.Action_PostPone_Expire == action then
        req.expired_ms = req.expired_ms + Rpc_Const.Default_Expire_Ms
        return
    end
    if Rpc_Const.Action_Return_Result == action or Rpc_Const.Action_Report_Error == action then
        local rpc_err = Rpc_Error.None
        if Rpc_Const.Action_Report_Error == action then
            rpc_err = Rpc_Error.Remote_Host_Error
        end
        self.req_list[req.id] = nil
        if req.cb_fn then
            req.cb_fn(rpc_err, self:unpack_params(msg.action_params))
        end
    end
end

function RpcMgrBase:handle_req_msg(from_host, pid, msg)
    -- msg contains id, fn_name, fn_params
    local rsp_id = self._next_unique_id()
    local rpc_rsp = RpcRsp:new(rsp_id, from_host, msg.req_id, self)
    self.rsp_list[rpc_rsp.id] = rpc_rsp
    if not msg.req_id or not msg.fn_name then
        self:response(rsp_id, from_host, msg.req_id, Rpc_Const.Action_Report_Error, "request miss req_id or fn_name")
        return
    end
    local fn = self.remote_call_handle_fn[msg.fn_name]
    if not fn then
        self:response(rsp_id, from_host, msg.req_id, Rpc_Const.Action_Report_Error, string.format("not found process function %s", msg.fn_name))
        return
    end
    fn(rpc_rsp, self:unpack_params(msg.fn_params))
end

function RpcMgrBase:on_frame()
    local now_ms = native.logic_ms()
    if  now_ms >= self.last_check_expired_ms + self.Check_Expired_Span_ms then
        self.last_check_expired_ms = now_ms
        local expired_req_ids = {}
        for id, req in pairs(self.req_list) do
            if now_ms > req.expired_ms then
                table.insert(expired_req_ids, id)
            end
        end
        for _, id in pairs(expired_req_ids) do
            local req = self.req_list[id]
            self.req_list[id] = nil
            if req.cb_fn then
                req.cb_fn(Rpc_Error.Wait_Expired)
            end
        end
    end

    local delay_execute_fns = self.delay_execute_fns
    self.delay_execute_fns = {}
    for _, fn in ipairs(delay_execute_fns) do
        safe_call(fn)
    end
end
