
Rpc_Pid = {}
Rpc_Pto = {}

Rpc_Pto.pto_files = {
    { [Proto_Const.pto_path]="rpc.pb", [Proto_Const.pto_type]=Proto_Const.Pb },
}

Rpc_Pto.id_to_pto = {}
local pto_tb = Rpc_Pto.id_to_pto

-- server建立连接时互相确认身份
Rpc_Pid.req_remote_call = 1 + Const.rpc_min_pto_id
Rpc_Pid.rsp_remote_call = 2 + Const.rpc_min_pto_id
setup_id_to_pb_pto(pto_tb, Rpc_Pid.req_remote_call, "ReqRemoteCall")
setup_id_to_pb_pto(pto_tb, Rpc_Pid.rsp_remote_call, "RspRemoteCall")