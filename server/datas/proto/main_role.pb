syntax="proto3"

message PullRoleData
{
	int32 pull_type = 1;
}


message RoleDataBaseInfo
{
	string role_name = 1;
}

message SyncRoleData
{
	int32 pull_type = 1
	int64 role_id = 2;
	RoleDataBaseInfo base_info = 3;
}