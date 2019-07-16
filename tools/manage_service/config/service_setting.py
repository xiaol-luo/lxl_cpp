from .common import *

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

login_service_count = 2
gate_service_count = 2
world_service_count = 2
game_service_count = 2
robot_service_count = 2

access_ip = "127.0.0.1"


def get_service_setting(zone_name):
    global  mongo_service, \
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
            robot_service_count
    ret, zone, zone_id = cal_zone_name(zone_name)
    if not ret:
        return  None
    setting = {}
    setting["mongo_service"] = mongo_service
    setting["etcd_service"] = etcd_service
    platforms = []
    platform_begin_port = 20000 + zone_id * 1000 + 1 * 10
    setting["platform_service"] = platforms
    for i in range(0, platform_service_count):
        platforms.append({
            "ip": access_ip,
            "port": platform_begin_port + i
        })
    return setting




