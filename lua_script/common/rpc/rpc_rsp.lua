

RpcRsp = RpcRsp or class("RpcRsp")

function RpcRsp:ctor()
    self.from_host = nil
    self.from_id = nil
    self.call_fn = nil
    self.call_fn_params = nil
    self.call_fn_params_count = nil
    self.delay_execute_fns = {}
end


