syntax="proto3"

message ReqLoginGame
{
	string token = 1;
	int64 timestamp = 2;
	string platform = 3;
}

message RspLoginGame
{
	int32 error_code = 1;
	string auth_sn = 2;
	int64 timestamp = 3;
}

