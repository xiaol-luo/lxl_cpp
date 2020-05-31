
Peer_Net_Pid = {}
Peer_Net_Pto = {}

Peer_Net_Pto.pto_files = {
    { [Proto_Const.pto_path]="peer_net.pb", [Proto_Const.pto_type]=Proto_Const.Pb },
}

Peer_Net_Pto.id_to_pto = {}
local pto_tb = Peer_Net_Pto.id_to_pto

-- server建立连接时互相确认身份
Peer_Net_Pid.req_handshake = 1 + Const.peer_net_min_pto_id
Peer_Net_Pid.rsp_handshake = 2 + Const.peer_net_min_pto_id
setup_id_to_pb_pto(pto_tb, Peer_Net_Pid.req_handshake, "ReqPeerNetHankShake")
setup_id_to_pb_pto(pto_tb, Peer_Net_Pid.rsp_handshake, "RspPeerNetHankShake")



