syntax="proto3"

message ReqUserLogin
{
	int64 user_id = 1;
    string app_id = 2;
    string auth_sn = 3;
	string auth_ip = 4;
	int32 auth_port = 5;
}

message RspUserLogin
{
    int32 error_num = 1;
}

message RoleDigest
{
    int64 role_id = 1;
}

message ReqPullRoleDigest
{
    int64 role_id = 1; // empty means pull all
}

message RspPullRoleDigest
{
	int32 error_num = 1;
    repeated RoleDigest role_digests = 2;
}

message ReqCreateRole
{
    string params = 1;
}

message RspCreateRole
{
    int32 error_num = 1;
	int64 role_id = 2;
}

message ReqLaunchRole
{
    int64 role_id = 1;
}

message RspLaunchRole
{
    int32 error_num = 1;
}

message ReqLogoutRole
{
	int64 role_id = 1;
}

message RspLogoutRole
{
	int32 error_num = 1;
}

message ReqReconnect
{
	ReqUserLogin user_login_msg = 1;
	int64 role_id = 2;
	int64 session_id = 3;
}

message RspReconnect
{
	int32 user_login_error_num = 1
	int32 role_launch_error_num = 2;
}
