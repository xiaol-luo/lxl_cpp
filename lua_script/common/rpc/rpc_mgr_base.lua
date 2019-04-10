
RpcMgrBase = RpcMgrBase or class("RpcMgrBase")

function RpcMgrBase:ctor()
    self.req_list = {}
    self.last_check_expired_ms = 0
    self.Check_Expired_Span_ms = 1000
end

function RpcMgrBase:init()

end

function RpcMgrBase:destory()
    self.req_list = {}
end

function RpcMgrBase:call(cb_fn, remote_host, remote_fn, ...)
    assert(remote_host)
    assert(remote_fn)
    local err = self:send(remote_host, remote_fn, ...)
    if Rpc_Error.None ~= err then
        if cb_fn then
            cb_fn(err)
        end
    else
        local req = RpcReq:new()
        req.id = NextRpcUniqueId()
        self.req_list[req.id] = req
        req.cb_fn = cb_fn
        req.expired_ms = native.logic_ms() + Rpc_Const.Default_Expire_Ms
        req.remote_host = remote_host
        req.remote_fn = remote_fn
    end
end

function RpcMgrBase:on_frame()
    local now_ms = native.logic_ms()
    if self.last_check_expired_ms + self.Check_Expired_Span_ms >= now_ms then
        self.last_check_expired_ms = now_ms
        local expired_req_ids = {}
        for id, req in pairs(self.req_list) do
            if req.expired_ms > now_ms then
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
end

function RpcMgrBase:on_msg(pid, block, ...)
    local is_ok, msg = self:decode_msg(pid, block)
    if not is_ok then
        return
    end
    -- msg contains req_id, action, action_params
    local req = self.req_list[msg.req_id]
    if not req then
        return
    end

    local action = req.action
    if action == Rpc_Const.Action_PostPone_Expire then
        req.expired_ms = req.expired_ms + Rpc_Const.Default_Expire_Ms
        return
    end
    if action == Rpc_Const.Action_Return_Result then
        self.req_list[req.id] = nil
        if req.cb_fn then
            req.cb_fn(Rpc_Error.None, table.unpack(msg.action_params))
        end
    end
end

function RpcMgrBase:send(remote_host, remote_fn, ...)
    assert("should not reach here")
end

function RpcMgrBase:decode_msg(pid, block)
    assert("should not reach here")
end