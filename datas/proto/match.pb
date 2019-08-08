syntax="proto3"

message SyncMatchState
{	
	
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

message ReqCancelMatch
{
	
}

message RspCancelMatch
{

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

