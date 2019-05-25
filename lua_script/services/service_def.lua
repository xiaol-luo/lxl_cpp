
Service_Const =
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
    Listen_Port = "listen_port",
    Listen_Ip = "listen_ip",
    Id = "id",
    Idx = "idx",
    Etcd_Cfg_File = "etcd_cfg_file",
    Zone = "zone",
    Service = "service",
    All_Service_Config = "all_service_config",
    Platform_Service = "platform_service",
    Etcd_Service = "etcd_service",
    Auth_Service = "auth_service",
    Mongo_Service = "mongo_service",
    Login = "login",
    Gate = "gate",
    World = "world",
    Game = "game",
    Element = "element",
    Name = "name",
    Service_Id = "service_id",
    Ip = "ip",
    Port = "port",
    For_Make_Array = "for_make_array",
    Host = "host",
    Auth_Db = "auth_db",
    User = "user",
    Pwd = "pwd",
    Db_name = "db_name",
    Client_Port = "client_port",
}

MAIN_ARGS_SERVICE = "service"
MAIN_ARGS_DATA_DIR = "data_dir"
MAIN_ARGS_CONFIG_FILE = "config_file"
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
