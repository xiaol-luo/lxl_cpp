
Proto_Const =
{
    Pb = "pb",
    Sproto = "sproto",
    Store = "store",
    Name = "name",
    Id = "id",
    Proto_Id = "proto_id",
    Proto_Type = "proto_type",
    Proto_Name = "proto_name"
}

System_Pid =
{
    Test_5 = 5,
    Test_6 = 6,
}
System_Proto_Files =
{
    [Proto_Const.Pb] =
    {
        "test_pb.txt",
    },

    [Proto_Const.Sproto] =
    {
        "test_sproto.txt",
    },
}

System_Pid_Proto_Map =
{
    { [Proto_Const.Proto_Id]=System_Pid.Test_5, [Proto_Const.Proto_Type]=Proto_Const.Sproto, [Proto_Const.Proto_Name]="TestSproto" },
    { [Proto_Const.Proto_Id]=System_Pid.Test_6, [Proto_Const.Proto_Type]=Proto_Const.Pb, [Proto_Const.Proto_Name]="TestPb" },
}
