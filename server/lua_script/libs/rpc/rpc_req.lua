
---@class RpcReq
RpcReq = RpcReq or class("RpcReq")

function RpcReq:ctor()
    self.id = nil
    self.cb_fn = nil
    self.expired_ms = 0
    self.remote_host = nil
    self.remote_fn = nil
end


