
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

public_ip = "127.0.0.1"
internal_ip = "127.0.0.1"


def get_service_setting():
    global mongo_service, etcd_service
    ret = {
        "mongo_service": mongo_service
    }
    return {}




