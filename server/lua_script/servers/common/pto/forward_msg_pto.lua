

Forward_Msg_Pto = {}
Forward_Msg_Pto.pto_files = {
    { [Pto_Const.pto_path]="forward_msg.pb", [Pto_Const.pto_type]=Pto_Const.Pb },
}

Forward_Msg_Pto.id_to_pto = {}
Forward_Msg_Pid = {}

-- server建立连接时互相确认身份
Forward_Msg_Pid.req_forward_game_msg = 1 + Pto_Const.forward_msg_min_pto_id
setup_id_to_pb_pto(Forward_Msg_Pto.id_to_pto, Forward_Msg_Pid.req_forward_game_msg, "ForwardGameMsg")



