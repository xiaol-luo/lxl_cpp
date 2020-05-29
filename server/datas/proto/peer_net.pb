syntax="proto3"

message ReqPeerNetHankShake
{
	string to_cluster_server_id = 1;
	string to_server_key = 2;
	string from_cluster_server_id = 3;
	string from_server_key = 4;
}

message RspPeerNetHankShake
{
	int32 error_num = 1;
	string error_msg = 2;
}





