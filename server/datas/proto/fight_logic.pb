syntax="proto3"

message SyncMatchState
{
	string state = 1;
	string match_theme = 2;
	string match_key = 3;
}

message ReqJoinMatch
{
	string match_theme = 1;
	repeated int64 teammate_role_ids = 2;
}

message RspJoinMatch
{
	int32 error_num = 1;
	SyncMatchState match_state = 2;
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

message SyncRoomState
{
	string state = 1;
	string room_key = 2;
	string remote_room_state = 3;
	string match_theme = 4;
	string fight_key = 5;
	string fight_server_ip = 6;
	int32 fight_server_port = 7;
	string fight_token = 8;
}

message AskCliAcceptEnterRoom
{
	string room_key = 1;
	string match_server_key = 2;
}

message RplSvrAcceptEnterRoom
{
	string room_key = 1;
	string match_server_key = 2;
	bool is_accept = 3;
}

message ReqBindFight
{
	string fight_key = 1;
	string token = 2;
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
}

message ReqFightOpera
{
	int64 unique_id = 1
	string opera = 2;
	string opera_params = 3;
}

message RspFightOpera
{
	int64 unique_id = 1
	int32 error_num = 2;
}

message PullFightState
{

}

message TwoDiceRound
{
	int32 round = 1;
	map<int64, int32> roll_points = 2;
}

message SyncFightStateTwoDice
{
	repeated TwoDiceRound rounds = 1;
	repeated int64 role_ids = 2;
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








