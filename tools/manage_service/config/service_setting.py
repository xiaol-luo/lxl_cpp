from .common import *
from enum import Enum
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

platform_service_count = 2
platform_service_db_name = "platform_account"

auth_service_count = 2
auth_service_auth_method = "app_auth"

uuid_db_name = "global_uuid"
uuid_coll_name = "uuids"

login_service_count = 2
gate_service_count = 2
world_service_count = 2
game_service_count = 2
robot_service_count = 2

access_ip = "127.0.0.1"


class Service_Type(Enum):
    platform = 1
    auth = 2
    login = 3
    world = 4
    game = 5
    robot = 6


All_Begin_Port = 30000
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
    ret, zone, zone_id = cal_zone_name(zone_name)
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
        platforms.append({
            "ip": access_ip,
            "port": platform_next_port,
            "mongo": mongo_setting,
        })
        platform_next_port += 1
    # auth service
    auths = []
    setting["auth_service"] = auths
    auth_next_port = cal_service_begin_port(zone_id, Service_Type.auth)
    platform_hosts = []
    for v in platforms:
        platform_hosts.append("{0}:{1}", v["ip"], v["port"])
    for i in range(0, auth_service_count):
        auths.append({
            "ip": access_ip,
            "port": auth_next_port,
            "platform": {
                "auth_method": "app_auth",
                "host": platform_hosts,
            }
        })
        auth_next_port += 1

    return setting




