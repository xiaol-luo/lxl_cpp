
syntax="proto3"


message ForwardMsg
{
	int32 pto_id = 1;
	bytes pto_bytes = 2;
	int32 further_forward = 3;
}

message ForwardGameMsg
{
	ForwardMsg msg = 1;
}
