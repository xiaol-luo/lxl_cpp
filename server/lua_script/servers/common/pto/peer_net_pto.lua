

Peer_Net_Pto = {}
Peer_Net_Pto.pto_files = {
    { [Pto_Const.pto_path]="peer_net.pb", [Pto_Const.pto_type]=Pto_Const.Pb },
}

Peer_Net_Pto.id_to_pto = {}
Peer_Net_Pid = {}

-- server建立连接时互相确认身份
Peer_Net_Pid.req_handshake = 1 + Pto_Const.peer_net_min_pto_id
Peer_Net_Pid.rsp_handshake = 2 + Pto_Const.peer_net_min_pto_id
setup_id_to_pb_pto(Peer_Net_Pto.id_to_pto, Peer_Net_Pid.req_handshake, "ReqPeerNetHankShake")
setup_id_to_pb_pto(Peer_Net_Pto.id_to_pto, Peer_Net_Pid.rsp_handshake, "RspPeerNetHankShake")



