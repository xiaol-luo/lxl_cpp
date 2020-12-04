syntax="proto3"

message ReqJoinMatch
{
	string match_theme = 1;
	repeated int64 teammate_role_ids = 2;
}

message RspJoinMatch
{
	int32 error_num = 1;
	string match_key = 2;
}

message ReqQuitMatch
{
	string match_key = 1;
	bool ignore_match_key = 2;
}

message RspQuitMatch
{
	int32 error_num = 1;
}

message SyncMatchState
{
	int32 state = 1;
	string match_theme = 2;
	string match_key = 3;
}


message SyncFightState
{
	int32 state = 1;
	string token = 2;
	string fight_type = 3;
	string fight_service_ip = 4;
	int32 fight_service_port = 5;
	int64 fight_battle_id = 6;
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

message RemoteRoomCommonHead
{
    int32 rpc_error_num = 1;    // 记录game和room之间的rpc通信机制错误
    int32 error_num = 2;        // 记录game与room之间的逻辑错误
}

message SyncRemoteRoomState
{
    RemoteRoomCommonHead head = 1;
    int64 room_id = 2;
    int32 state = 3;
    int32 fight_type = 4;
}




message ReqBindFight
{
	int64 fight_id = 1;
	int64 fight_session_id = 2;
	int64 role_id = 3;
}

message RspBindFight
{
	int32 error_num = 1;
}

message ReqQuitFight
{
	
}

message RspQuitFight
{
	int32 error_num = 1;
	string error_msg = 2;
}

message PullFightState
{

}

message ReqFightOpera
{
	string opera = 1;
	string opera_params = 2;
}

message RspFightOpera
{
	int32 error_num = 1;
	string opera_ret = 2;
}

message SyncRollPointResult
{
	map<int64, int32> role_roll_points = 1;
}




