

RpcRsp = RpcRsp or class("RpcRsp")

function RpcRsp:ctor(id, from_host, from_id, rpc_mgr)
    self.id = id
    self.from_host = from_host
    self.from_id = from_id
    self.rpc_mgr = rpc_mgr
    self.co = nil
    -- self.call_fn_params = nil
    -- self.call_fn_params_count = nil
    self.delay_execute_fns = {}
end

function RpcRsp:respone(...)
    -- self.rpc_mgr:respone(self.id, self.from_host, self.from_id, Rpc_Const.Action_Return_Result, ...)
    self:send_back(Rpc_Const.Action_Return_Result, ...)
end

function RpcRsp:report_error(err_str)
    -- self.rpc_mgr:respone(self.id, self.from_host, self.from_id, Rpc_Const.Action_Report_Error, err_str)
    self:send_back(Rpc_Const.Action_Report_Error, err_str)
end

function RpcRsp:postpone_expire()
    -- self.rpc_mgr:respone(self.id, self.from_host, self.from_id, Rpc_Const.Action_PostPone_Expire)
    self:send_back(Rpc_Const.Action_PostPone_Expire)
end

function RpcRsp:add_delay_execute(fn)
    table.insert(self.delay_execute_fns, fn)
end

function RpcRsp:send_back(rpc_action, ...)
    self.rpc_mgr:respone(self.id, self.from_host, self.from_id, rpc_action, ...)
end