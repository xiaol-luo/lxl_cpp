
ZoneServiceRpcMgr = ZoneServiceRpcMgr or class("ZoneServiceRpcMgr", RpcMgrBase)

function ZoneServiceRpcMgr:ctor()
    self.super:ctor()
    self.msg_handler = nil
end

function ZoneServiceRpcMgr:init(zs_msg_handler)
    self.super:init()
    self.msg_handler = zs_msg_handler
    self.msg_handler:set_handler_msg_fn(System_Pid.Zone_Service_Rpc_Rsp, function(from_service, pid, msg)
        self:on_msg(from_service, pid, msg)
    end)
end

function ZoneServiceRpcMgr:destory()
    self.super:destory()
    if self.msg_handler then
        self.msg_handler:set_handler_msg_fn(System_Pid.Zone_Service_Rpc_Rsp, nil)
    end
end

function ZoneServiceRpcMgr:send(remote_host, remote_fn, ...)
    local ret = Rpc_Error.Unknown
    if self.msg_handler then
        local msg = {}
        -- Todo:
        if self.msg_handler:send(remote_host, System_Pid.Zone_Service_Rpc_Req, msg) then
           ret = Rpc_Error.None
        end
    end
    return ret
end

function ZoneServiceRpcMgr:decode_msg(pid, msg)
    return true, msg
end