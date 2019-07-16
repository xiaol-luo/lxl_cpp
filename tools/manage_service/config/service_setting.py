
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

platform_service = [
    {
        "ip": "127.0.0.1",
        "port": 20100,
    },
    {
        "ip": "127.0.0.1",
        "port": 20101,
    },
]
platform_service_db_name = "platform_account"

auth_service = [
    {
        "ip": "127.0.0.1",
        "port": 20200,
    },
    {
        "ip": "127.0.0.1",
        "port": 20201,
    },
]
auth_service_auth_method = "app_auth"

login_service = [
    {
        "ip": "127.0.0.1",
        "port": 31000,
    },
    {
        "ip": "127.0.0.1",
        "port": 20201,
    },
]

