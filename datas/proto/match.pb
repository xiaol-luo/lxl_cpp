syntax="proto3"

message SyncMatchState
{	
	int32 state = 1;
}

message ReqJoinMatch
{
	int32 match_type = 1;
}

message RspJoinMatch
{
    int32 match_type = 1
    int32 error_num = 2;
}

message ReqQuitMatch
{
	
}

message RspQuitMatch
{
	int32 error_num = 1;
}

message NotifyConfirmMatch
{
}

message ReqConfirmMatch
{
}

message RspConfirmMatch
{
}

message SyncRoomState
{
}

