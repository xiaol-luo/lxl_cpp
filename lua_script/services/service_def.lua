
Service_Cfg_Const =
{
    Root = "root",
    Etcd = "etcd",
    Etcd_Host = "host",
    Etcd_User = "user",
    Etcd_Pwd = "pwd",
    Etcd_Root_Dir = "root_dir",
    Etcd_Ttl = "ttl",
    Services = "services",
    Avatar = "avatar",
    Instance = "instance",
    Listen_Peer_Port = "listen_peer_port",
    Id = "id",
}

MAIN_ARGS_SERVICE_FULL_NAME = "service" -- MAIN_ARGS[MAIN_ARGS_SERVICE_NAME].MAIN_ARGS[MAIN_ARGS_SERVICE_IDX]
MAIN_ARGS_SERVICE_NAME = "service_name"
MAIN_ARGS_SERVICE_IDX = "service_idx"
MAIN_ARGS_ZONE_NAME = "zone_name"
MAIN_ARGS_DATA_DIR = "data_dir"
MAIN_ARGS_LOGIC_PARAM = "logic_param"

MICRO_SEC_PER_SEC = 1000
SERVICE_FRAME_PER_SEC = 30
SERVICE_MICRO_SEC_PER_FRAME = MICRO_SEC_PER_SEC / SERVICE_FRAME_PER_SEC

function combine_service_full_name(service_name, service_idx)
    local ret = string.format("%s.%s", service_name, service_idx)
    return ret
end

function extract_service_name_idx(service_full_name)
    local service_name = native.extract_service_name(service_full_name)
    local service_idx = native.extract_service_idx(service_full_name)
    return service_name, service_idx
end
