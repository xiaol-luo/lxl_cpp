

Rpc_Pto = {}
Rpc_Pto.pto_files = {
    { [Pto_Const.pto_path]="rpc.pb", [Pto_Const.pto_type]=Pto_Const.Pb },
}

Rpc_Pto.id_to_pto = {}
Rpc_Pid = {}

-- server建立连接时互相确认身份
Rpc_Pid.req_remote_call = 1 + Pto_Const.rpc_min_pto_id
Rpc_Pid.rsp_remote_call = 2 + Pto_Const.rpc_min_pto_id
setup_id_to_pb_pto(Rpc_Pto.id_to_pto, Rpc_Pid.req_remote_call, "ReqRemoteCall")
setup_id_to_pb_pto(Rpc_Pto.id_to_pto, Rpc_Pid.rsp_remote_call, "RspRemoteCall")