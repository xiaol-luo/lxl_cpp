syntax="proto3"

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

message SyncFightState
{
	int32 error_num = 1;
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




