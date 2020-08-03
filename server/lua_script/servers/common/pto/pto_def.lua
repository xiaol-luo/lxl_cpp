
Pto_Const =
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
    pto_tb[id] = { [Pto_Const.pto_id]=id, [Pto_Const.pto_type]=pto_type, [Pto_Const.pto_name]=pto_name }
end

function setup_id_to_pb_pto(pto_tb, id, pto_name)
    setup_id_to_pto(pto_tb, id, Pto_Const.Pb, pto_name)
end

function setup_id_to_sproto_pto(pto_tb, id, pto_name)
    setup_id_to_pto(pto_tb, id, Pto_Const.Sproto, pto_name)
end

Pto_Const.peer_net_min_pto_id = 2000
Pto_Const.rpc_min_pto_id = 3000
Pto_Const.login_min_pto_id = 4000
Pto_Const.forward_msg_min_pto_id = 5000
Pto_Const.main_role_min_pto_id = 6000


require("servers.common.pto.peer_net_pto")
require("servers.common.pto.rpc_pto")
require("servers.common.pto.login_pto")
require("servers.common.pto.forward_msg_pto")
require("servers.common.pto.main_role_pto")

