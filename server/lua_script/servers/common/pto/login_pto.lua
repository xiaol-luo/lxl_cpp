
Login_Pto = {}
Login_Pto.pto_files = {
    { [Pto_Const.pto_path]="login_logic.pb", [Pto_Const.pto_type]=Pto_Const.Pb },
}

Login_Pto.id_to_pto = {}
Login_Pid = {}

-- 请求登录（连gate server）
Login_Pid.req_user_login = 1 + Pto_Const.login_min_pto_id
Login_Pid.rsp_user_login = 2 + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.req_user_login, "ReqUserLogin")
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.rsp_user_login, "RspUserLogin")

-- 拉去玩家信息
Login_Pid.req_pull_role_digest = 3 + Pto_Const.login_min_pto_id
Login_Pid.rsp_pull_role_digest = 4 + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.req_pull_role_digest, "ReqPullRoleDigest")
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.rsp_pull_role_digest, "RspPullRoleDigest")

-- 创建角色
Login_Pid.req_create_role = 5 + Pto_Const.login_min_pto_id
Login_Pid.rsp_create_role = 6 + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.req_create_role, "ReqCreateRole")
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.rsp_create_role, "RspCreateRole")

-- 请求launch role
Login_Pid.req_launch_role = 7 + Pto_Const.login_min_pto_id
Login_Pid.rsp_launch_role = 8 + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.req_launch_role, "ReqLaunchRole")
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.rsp_launch_role, "RspLaunchRole")

-- 请求登出
Login_Pid.req_logout_role = 9 + Pto_Const.login_min_pto_id
Login_Pid.rsp_logout_role = 10 + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.req_logout_role, "ReqLogoutRole")
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.rsp_logout_role, "RspLogoutRole")

-- 请求重连
Login_Pid.req_reconnect_role = 11 + Pto_Const.login_min_pto_id
Login_Pid.rsp_reconnect_role = 12 + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.req_reconnect_role, "ReqReconnectRole")
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.rsp_reconnect_role, "RspReconnectRole")

-- 请求转发到game
Login_Pid.forward_game_msg = 13  + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.forward_game_msg, "ForwardGameMsg")

-- 请求登录（连login server）
Login_Pid.req_login_game = 15 + Pto_Const.login_min_pto_id
Login_Pid.rsp_login_game = 16 + Pto_Const.login_min_pto_id
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.req_login_game, "ReqLoginGame")
setup_id_to_pb_pto(Login_Pto.id_to_pto, Login_Pid.rsp_login_game, "RspLoginGame")

