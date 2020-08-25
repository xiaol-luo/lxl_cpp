syntax="proto3"

message ReqUserLogin
{
	int64 user_id = 1;
    string app_id = 2;
    string token = 3;
	string token_timestamp = 4;
	string auth_ip = 5;
	int32 auth_port = 6;
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
	int64 role_id = 2; // empty means pull all
    repeated RoleDigest role_digests = 3;
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
	int64 role_id = 2;
}

message ReqLogoutRole
{
	int64 role_id = 1;
}

message RspLogoutRole
{
	int32 error_num = 1;
}

message ReqReconnectRole
{
	ReqUserLogin user_login_msg = 1;
	int64 role_id = 2;
}

message RspReconnectRole
{
	int32 error_num = 1;
	int64 role_id = 2;
}

message ReqLoginGame
{
	string token = 1;
	string timestamp = 2;
	string platform = 3;
	string account_id = 5;
	string app_id = 6;
}

message RspLoginGame
{
	int32 error_num = 1;
	string token = 2;
	string timestamp = 3;
	int64 user_id = 4;
	string auth_ip = 5;
	int32 auth_port = 6;
}

