from .common import *
import copy

mongo_service = {
    "host": "127.0.0.1:27017",
    "auth_db": "admin",
    "user": "lxl",
    "pwd": "xiaolzz",
}

etcd_service = {
    "host": "http://127.0.0.1:2379",
    "user": "root",
    "pwd": "xiaolzz",
    "ttl": 10,
}

platform_service_count = 1
platform_service_db_name = "platform_account"

auth_service_count = 1
auth_service_auth_method = "app_auth"

uuid_db_name = "global_uuid"
uuid_coll_name = "uuids"

login_service_count = 2
gate_service_count = 2
world_service_count = 2
game_service_count = 2
robot_service_count = 2

access_ip = "127.0.0.1"

All_Begin_Port = 40000
Zone_Port_Span = 1000
Service_Port_Span = 100


def cal_service_begin_port(zone_id, service_type):
    global Zone_Port_Span, \
        Service_Port_Span, \
        All_Begin_Port
    return All_Begin_Port + Zone_Port_Span * zone_id + Service_Port_Span * service_type


def get_service_setting(zone_name):
    global mongo_service, \
        etcd_service, \
        platform_service_count, \
        platform_service_db_name, \
        auth_service_count, \
        auth_service_auth_method, \
        login_service_count, \
        gate_service_count, \
        world_service_count, \
        game_service_count, \
        access_ip, \
        Zone_Port_Span, \
        Service_Port_Span, \
        All_Begin_Port, \
        robot_service_count
    ret, zone, zone_id = parse_zone_name(zone_name)
    if not ret:
        return None
    setting = dict()
    # mongo service
    mongo_service_name = zone_name
    setting["mongo_service"] = copy.deepcopy(mongo_service)
    setting["mongo_service"]["name"] = mongo_service_name
    # uuid mongo service
    uuid_mongo_service_name = "uuid_{0}".format(zone_name)
    setting["uuid_mongo_service"] = copy.deepcopy(mongo_service)
    setting["uuid_mongo_service"]["name"] = uuid_mongo_service_name
    setting["uuid_mongo_service"]["db_name"] = uuid_db_name
    setting["uuid_mongo_service"]["coll_name"] = uuid_coll_name
    #etcd service
    etcd_service_name = zone_name
    setting["etcd_service"] = copy.deepcopy(etcd_service)
    setting["etcd_service"]["name"] = etcd_service_name
    # platform service
    platforms = []
    setting["platform_service"] = platforms
    platform_next_port = cal_service_begin_port(zone_id, Service_Type.platform)
    for i in range(0, platform_service_count):
        mongo_setting = copy.deepcopy(mongo_service)
        mongo_service["db"] = platform_service_db_name
        mongo_service["mongo_service"] = mongo_service_name
        platforms.append({
            "role": "platform",
            "name": zone_name,
            "ip": access_ip,
            "port": platform_next_port,
            "mongo": mongo_setting,
            "db": platform_service_db_name,
        })
        platform_next_port += 1
    # auth service
    auths = []
    setting["auth_service"] = auths
    auth_next_port = cal_service_begin_port(zone_id, Service_Type.auth)
    platform_hosts = []
    for v in platforms:
        platform_hosts.append("{0}:{1}".format(v["ip"], v["port"]))
    for i in range(0, auth_service_count):
        auths.append({
            "role": "auth",
            "ip": access_ip,
            "name": zone_name,
            "port": auth_next_port,
            "auth_method": "app_auth",
            "platform": {
                "auth_method": "app_auth",
                "host": platform_hosts,
            }
        })
        auth_next_port += 1
    # login service
    logins = []
    setting["login_service"] = logins
    login_next_port = cal_service_begin_port(zone_id, Service_Type.login)
    for i in range(0, login_service_count):
        service_id = login_next_port
        logins.append({
            "role": "login",
            "zone": zone_name,
            "idx": i,
            "service_idx": service_id,
            "ip": access_ip,
            "port": login_next_port,
            "client_port": login_next_port + 1,
            "mongo_service": mongo_service_name,
            "db_name": "{0}_login".format(zone_name),
            "uuid_mongo_service": uuid_mongo_service_name,
        })
        login_next_port += 2
    # gate service
    gates = []
    setting["gate_service"] = gates
    gate_next_port = cal_service_begin_port(zone_id, Service_Type.gate)
    for i in range(0, gate_service_count):
        service_id = gate_next_port
        gates.append({
            "role": "gate",
            "zone": zone_name,
            "idx": i,
            "service_idx": service_id,
            "ip": access_ip,
            "port": gate_next_port,
            "client_ip": access_ip,
            "client_port": gate_next_port + 1,
        })
        gate_next_port += 2
    # world service
    game_service_db_name = "{0}_game".format(zone_name)
    worlds = []
    setting["world_service"] = worlds
    world_next_port = cal_service_begin_port(zone_id, Service_Type.world)
    for i in range(0, world_service_count):
        service_id = world_next_port
        worlds.append({
            "role": "world",
            "zone": zone_name,
            "idx": i,
            "service_idx": service_id,
            "ip": access_ip,
            "port": world_next_port,
            "mongo_service": mongo_service_name,
            "db_name": game_service_db_name,
            "uuid_mongo_service": uuid_mongo_service_name,
        })
        world_next_port += 1
    # game service
    games = []
    setting["game_service"] = games
    game_next_port = cal_service_begin_port(zone_id, Service_Type.game)
    for i in range(0, game_service_count):
        service_id = game_next_port
        games.append({
            "role": "game",
            "zone": zone_name,
            "idx": i,
            "service_idx": service_id,
            "ip": access_ip,
            "port": game_next_port,
            "mongo_service": mongo_service_name,
            "db_name": game_service_db_name,
        })
        game_next_port += 1
    # robot service
    robots = []
    setting["robot_service"] = robots
    robot_next_port = cal_service_begin_port(zone_id, Service_Type.robot)
    for i in range(0, robot_service_count):
        service_id = robot_next_port
        robots.append({
            "role": "robot",
            "zone": zone_name,
            "idx": i,
            "service_idx": service_id,
            "ip": access_ip,
            "port": robot_next_port,
        })
        robot_next_port += 1
    return setting




