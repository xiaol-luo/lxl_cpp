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
	string session_id = 1;
	int64 room_id = 2;
	int32 state = 3;
	int32 join_match_type = 4;
	string fight_service_ip = 5;
	int32 fight_service_port = 6;
	int64 fight_battle_id = 7;
	bool is_fight_started = 8;
}

message NotifyBindRoom
{
	string session_id = 1;
	int64 room_id = 2;
}

message NotifyUnbindRoom
{
	string session_id = 1;
	int64 room_id = 2;
}

message NotifyTerminateRoom
{
	string session_id = 1;
	int64 room_id = 2;
}

