

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

-- 同步匹配信息
Fight_Pid.pull_match_state = 5 + Pto_Const.fight_min_pto_id
Fight_Pid.sync_match_state = 6 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.sync_match_state, "SyncMatchState")

-- 同步房间信息
Fight_Pid.pull_room_state = 7 + Pto_Const.fight_min_pto_id
Fight_Pid.sync_room_state = 8 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.sync_room_state, "SyncRoomState")

-- 询问前端进入房间
Fight_Pid.ask_cli_accept_enter_room = 9 + Pto_Const.fight_min_pto_id
Fight_Pid.rpl_svr_accept_enter_room = 10 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.ask_cli_accept_enter_room, "AskCliAcceptEnterRoom")
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.rpl_svr_accept_enter_room, "RplSvrAcceptEnterRoom")

-- 绑定战斗
Fight_Pid.req_bind_fight = 51 + Pto_Const.fight_min_pto_id
Fight_Pid.rsp_bind_fight = 52 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.req_bind_fight, "ReqBindFight")
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.rsp_bind_fight, "RspBindFight")

-- 同步战斗状态
Fight_Pid.pull_fight_state = 53 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.pull_fight_state, "PullFightState")

-- 战斗操作
Fight_Pid.req_fight_opera = 55 + Pto_Const.fight_min_pto_id
Fight_Pid.rsp_fight_opera = 56 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.req_fight_opera, "ReqFightOpera")
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.rsp_fight_opera, "RspFightOpera")


-- Two Dice Pto
Fight_Pid.two_dice_sync_curr_round = 100 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.two_dice_sync_curr_round, "TwoDiceRound")

Fight_Pid.two_dice_sync_brief_state = 101 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.two_dice_sync_brief_state, "TwoDiceBriefState")

Fight_Pid.two_dice_sync_fight_state = 102 + Pto_Const.fight_min_pto_id
setup_id_to_pb_pto(Fight_Pto.id_to_pto, Fight_Pid.two_dice_sync_fight_state, "TwoDiceSyncFightState")







