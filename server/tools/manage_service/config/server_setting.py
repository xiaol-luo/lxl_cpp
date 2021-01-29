from .common import *
from .etcd_setting import gen_setting as gen_etcd_setting
from .mongo_setting import gen_setting as gen_mongo_setting
from .redis_setting import gen_setting as gen_redis_setting


class RemoteServerHost(object):
    def __init__(self):
        self.name = ""
        self.ip = ""
        self.port = ""


class GameServerSetting(object):
    def __init__(self):
        self.zone = ""
        self.role = ""
        self.name = ""
        self.peer_ip = ""
        self.client_ip = ""
        self.peer_port = 0
        self.client_port = 0
        self.http_port = 0
        self.remote_server_list = []
        self.etcd_server_map = {}
        self.mongo_server_map = {}
        self.redis_server_map = {}


Client_Ip = "127.0.0.1"

def gen_platform_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(30000)
    ret = []
    setting = GameServerSetting()
    ret.append(setting)
    setting.zone = parse_ret.zone
    setting.role = "platform"
    setting.name = "platform_0"
    setting.client_ip = Client_Ip
    setting.peer_ip = "127.0.0.1"
    setting.peer_port = next_num()
    setting.client_port = next_num()
    setting.http_port = next_num()

    mongo_cluster_setting = gen_mongo_setting(parse_ret)
    setting.mongo_server_map["platform"] = mongo_cluster_setting
    return ret


def gen_auth_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(32000)
    ret = []
    setting = GameServerSetting()
    ret.append(setting)
    setting.zone = parse_ret.zone
    setting.role = "auth"
    setting.name = "auth_0"
    setting.client_ip = Client_Ip
    setting.peer_ip = "127.0.0.1"
    setting.peer_port = next_num()
    setting.client_port = next_num()
    setting.http_port = next_num()

    mongo_cluster_setting = gen_mongo_setting(parse_ret)
    setting.mongo_server_map["auth"] = mongo_cluster_setting
    setting.mongo_server_map["uuid"] = mongo_cluster_setting

    remote_sh = RemoteServerHost()
    setting.remote_server_list.append(remote_sh)
    remote_sh.name = "platform_http"
    platform_setting = gen_platform_setting(parse_ret)
    remote_sh.ip = platform_setting[0].client_ip
    remote_sh.port = platform_setting[0].http_port
    return ret


def gen_login_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(31000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "login"
        setting.name = "login_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        mongo_cluster_setting = gen_mongo_setting(parse_ret)
        setting.mongo_server_map["login"] = mongo_cluster_setting

        remote_sh = RemoteServerHost()
        setting.remote_server_list.append(remote_sh)
        remote_sh.name = "auth_http"
        auth_setting = gen_auth_setting(parse_ret)
        remote_sh.ip = auth_setting[0].client_ip
        remote_sh.port = auth_setting[0].http_port
    return ret


def gen_create_role_settting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(37000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "create_role"
        setting.name = "create_role_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        mongo_cluster_setting = gen_mongo_setting(parse_ret)
        setting.mongo_server_map["game"] = mongo_cluster_setting
        setting.mongo_server_map["uuid"] = mongo_cluster_setting

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting
    return ret


def gen_world_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(33000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "world"
        setting.name = "world_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        mongo_cluster_setting = gen_mongo_setting(parse_ret)
        setting.mongo_server_map["game"] = mongo_cluster_setting

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting

        redis_cluster_setting = gen_redis_setting(parse_ret)
        setting.redis_server_map["online_servers"] = redis_cluster_setting
    return ret


def gen_game_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(36000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "game"
        setting.name = "game_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        mongo_cluster_setting = gen_mongo_setting(parse_ret)
        setting.mongo_server_map["game"] = mongo_cluster_setting

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting

        redis_cluster_setting = gen_redis_setting(parse_ret)
        setting.redis_server_map["online_servers"] = redis_cluster_setting
    return ret


def gen_gate_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(35000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "gate"
        setting.name = "gate_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting

        redis_cluster_setting = gen_redis_setting(parse_ret)
        setting.redis_server_map["online_servers"] = redis_cluster_setting
    return ret


def gen_match_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(40000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "match"
        setting.name = "match_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting
    return ret


def gen_room_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(41000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "room"
        setting.name = "room_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting
    return ret


def gen_fight_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(42000)
    ret = []
    for i in range(0, 2):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "fight"
        setting.name = "fight_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting
    return ret


def gen_world_sentinel_setting(parse_ret):
    global Client_Ip
    next_num = next_num_fn(34000)
    ret = []
    for i in range(0, 1):
        setting = GameServerSetting()
        ret.append(setting)
        setting.zone = parse_ret.zone
        setting.role = "world_sentinel"
        setting.name = "world_sentinel_{}".format(i)
        setting.client_ip = Client_Ip
        setting.peer_ip = "127.0.0.1"
        setting.peer_port = next_num()
        setting.client_port = next_num()
        setting.http_port = next_num()

        etcd_cluster_setting = gen_etcd_setting(parse_ret)
        setting.etcd_server_map["service_discovery"] = etcd_cluster_setting

        redis_cluster_setting = gen_redis_setting(parse_ret)
        setting.redis_server_map["online_servers"] = redis_cluster_setting
    return ret


def gen_setting(parse_ret):
    ret = dict()
    ret[Service_Type.platform] = gen_platform_setting(parse_ret)
    ret[Service_Type.auth] = gen_auth_setting(parse_ret)
    ret[Service_Type.login] = gen_login_setting(parse_ret)
    ret[Service_Type.world] = gen_world_setting(parse_ret)
    ret[Service_Type.game] = gen_game_setting(parse_ret)
    ret[Service_Type.gate] = gen_gate_setting(parse_ret)
    ret[Service_Type.match] = gen_match_setting(parse_ret)
    ret[Service_Type.fight] = gen_fight_setting(parse_ret)
    ret[Service_Type.room] = gen_room_setting(parse_ret)
    ret[Service_Type.create_role] = gen_create_role_settting(parse_ret)
    ret[Service_Type.world_sentinel] = gen_world_sentinel_setting(parse_ret)
    return ret

