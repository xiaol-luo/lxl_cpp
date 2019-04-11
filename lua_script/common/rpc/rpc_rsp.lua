

RpcRsp = RpcRsp or class("RpcRsp")

function RpcRsp:ctor(from_host, from_id)
    self.from_host = from_host
    self.from_id = from_id
    self.call_fn_params = nil
    self.call_fn_params_count = nil
    self.delay_execute_fns = {}
end


