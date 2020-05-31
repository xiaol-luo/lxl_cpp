syntax="proto3"

message ReqRemoteCall
{
	int64 req_id = 1;
	string fn_name = 2;
	string fn_params = 3;
}

message RspRemoteCall
{
	int64 req_id = 1;
	string action = 2;
	string action_params = 3;
}





