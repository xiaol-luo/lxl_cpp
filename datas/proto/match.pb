syntax="proto3"

message ReqJoinMatch
{
	int32 match_type = 1;
}

message RspJoinMatch
{
    int32 match_type = 1
    int32 error_num = 2;
}
