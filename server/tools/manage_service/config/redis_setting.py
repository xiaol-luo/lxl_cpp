from .common import *
import copy


class RedisNodeSetting(object):
    def __init__(self):
        self.name = ""
        self.dir = ""
        self.port = 0
        self.peer_ip = ""
        self.client_ip = ""
        self.pid_file = ""
        self.log_file = ""
        self.cluster_config_file = ""
        self.db_file_name = ""
        self.append_file_name = ""


class RedisClusterSetting(object):
    def __init__(self):
        self.node_list = []
        self.work_dir = ""
        self.run_dir = ""
        self.auth_pwd = ""
        self.thread_num = 3
        self.cnn_timeout_ms = 3000
        self.cmd_timeout_ms = 3000

    def get_client_hosts(self):
        str_list = []
        for node in self.node_list:
            str_list.append("{}:{}".format(node.client_ip, node.port))
        ret = ",".join(str_list)
        return ret


def gen_setting(parse_ret):
    ret = RedisClusterSetting()
    cluster_dir = cal_path_redis_cluster_dir(parse_ret)
    run_dir = "{}/{}".format(cluster_dir, "run")
    ret.work_dir = cluster_dir
    ret.run_dir = run_dir
    ret.auth_pwd = "xiaolzz"
    ret.thread_num = 3
    ret.cnn_timeout_ms = 3000
    ret.cmd_timeout_ms = 3000

    begin_port = 7000
    for i in range(0, 6):
        port = begin_port + i
        node = RedisNodeSetting()
        node.name = "redis_{}".format(port)
        node.dir = run_dir
        node.port = port
        node.client_ip = "127.0.0.1"
        node.peer_ip = "127.0.0.1"
        node.pid_file = "{}.pid".format(node.name)
        node.log_file = "{}.log".format(node.name)
        node.cluster_config_file = "{}.conf".format(node.name)
        node.db_file_name = "{}.rdb".format(node.name)
        node.append_file_name = "{}.aof".format(node.name)
        ret.node_list.append(node)
    return ret

