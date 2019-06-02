syntax="proto3"

message ReqUserLogin
{
	string user_id = 1;
    string app_id = 2;
    string auth_sn = 3;
	string auth_ip = 4;
	int32 auth_port = 5;
}

message RspUserLogin
{
    int32 error_num = 1;
    string error_msg = 2;
}

message RoleDigest
{
    string role_id = 1;
}

message ReqPullRoleDigest
{
    string role_id = 1; // empty means pull all
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
    string error_msg = 2;
	string role_id = 3;
}

message ReqLaunchRole
{
    string role_id = 1;
}

message RspLaunchRole
{
    int32 error_num = 1;
    string error_msg = 2;
}
