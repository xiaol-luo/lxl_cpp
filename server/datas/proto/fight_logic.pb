syntax="proto3"

message ReqJoinMatch
{
	int32 fight_type = 1;
}

message RspJoinMatch
{
    int32 fight_type = 1
    int32 error_num = 2;
}

message ReqQuitMatch
{
	
}

message RspQuitMatch
{
	int32 error_num = 1;
}


message SyncFightState
{
	string session_id = 1;
	int64 room_id = 2;
	int32 state = 3;
	int32 join_fight_type = 4;
	string fight_service_ip = 5;
	int32 fight_service_port = 6;
	int64 fight_battle_id = 7;
	bool is_fight_started = 8;
	int64 fight_session_id = 9;
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



