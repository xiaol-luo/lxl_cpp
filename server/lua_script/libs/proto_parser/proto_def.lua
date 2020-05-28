
Proto_Const =
{
    Pb = "pb",
    Sproto = "sproto",
    Store = "store",
    Name = "name",
    Id = "id",
    pto_id = "pto_id",
    pto_type = "pto_type",
    pto_name = "pto_name",
    pto_path = "pto_path",
}

function setup_pto_id(pto_id_tb, pid_name, pid_num)
    assert(pto_id_tb and pid_name and pid_num)
    pto_id_tb[pid_name] = pid_num
end

function setup_id_to_pto(pto_tb, id, pto_type, pto_name)
    assert(pto_tb and id and pto_type and pto_name)
    assert(not pto_tb[id])
    pto_tb[id] = { [Proto_Const.pto_id]=id, [Proto_Const.pto_type]=pto_type, [Proto_Const.pto_name]=pto_name }
end

function setup_id_to_pb_pto(pto_tb, id, pto_name)
    setup_id_to_pto(pto_tb, id, Proto_Const.Pb, pto_name)
end

function setup_id_to_sproto_pto(pto_tb, id, pto_name)
    setup_id_to_pto(pto_tb, id, Proto_Const.Sproto, pto_name)
end

System_Pid =
{
    Test_5 = 5,
    Test_6 = 6,
    Zone_Service_Rpc_Req = 7,
    Zone_Service_Rpc_Rsp = 8,
}

System_Proto_Files =
{
    [Proto_Const.Pb] =
    {
        "test_pb.txt",
        "zone_service_rpc.pb",
    },

    [Proto_Const.Sproto] =
    {
        "test_sproto.txt",
    },
}

System_Pid_Proto_Map =
{
    { [Proto_Const.pto_id]=System_Pid.Test_5, [Proto_Const.pto_type]=Proto_Const.Sproto, [Proto_Const.pto_name]="TestSproto" },
    { [Proto_Const.pto_id]=System_Pid.Test_6, [Proto_Const.pto_type]=Proto_Const.Pb, [Proto_Const.pto_name]="TestPb" },

    { [Proto_Const.pto_id]=System_Pid.Zone_Service_Rpc_Req, [Proto_Const.pto_type]=Proto_Const.Pb, [Proto_Const.pto_name]="RpcRequest" },
    { [Proto_Const.pto_id]=System_Pid.Zone_Service_Rpc_Rsp, [Proto_Const.pto_type]=Proto_Const.Pb, [Proto_Const.pto_name]="RpcResponse" },
}
