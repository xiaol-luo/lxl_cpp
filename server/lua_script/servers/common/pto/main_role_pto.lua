

Main_Role_Pto = {}
Main_Role_Pto.pto_files = {
    { [Pto_Const.pto_path]="main_role.pb", [Pto_Const.pto_type]=Pto_Const.Pb },
}

Main_Role_Pto.id_to_pto = {}
Main_Role_Pid = {}

-- 拉取角色数据
Main_Role_Pid.pull_role_data = 1 + Pto_Const.main_role_min_pto_id
setup_id_to_pb_pto(Main_Role_Pto.id_to_pto, Main_Role_Pid.pull_role_data, "PullRoleData")
Main_Role_Pid.sync_role_data = 2 + Pto_Const.main_role_min_pto_id
setup_id_to_pb_pto(Main_Role_Pto.id_to_pto, Main_Role_Pid.sync_role_data, "SyncRoleData")





