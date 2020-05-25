syntax="proto3"

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
    int32 match_type = 4;
}

