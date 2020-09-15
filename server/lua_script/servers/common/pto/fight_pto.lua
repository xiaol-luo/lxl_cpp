

Fight_Pto = {}
Fight_Pto.pto_files = {
    { [Pto_Const.pto_path]="fight_logic.pb", [Pto_Const.pto_type]=Pto_Const.Pb },
}

Fight_Pto.id_to_pto = {}
Fight_Pid = {}

-- 请求参与匹配
Fight_Pid.req_join_match = 1 + Pto_Const.fight_min_pto_id
Fight_Pid.rsp_join_match = 2 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.req_join_match, "ReqJoinMatch")
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.rsp_join_match, "RspJoinMatch")

-- 退出匹配
Fight_Pid.req_quit_match = 3 + Pto_Const.fight_min_pto_id
Fight_Pid.rsp_quit_match = 4 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.req_quit_match, "ReqQuitMatch")
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.rsp_quit_match, "RspQuitMatch")

-- 同步信息
Fight_Pid.query_fight_state = 5 + Pto_Const.fight_min_pto_id
Fight_Pid.sync_fight_state = 6 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.sync_fight_state, "SyncFightState")










