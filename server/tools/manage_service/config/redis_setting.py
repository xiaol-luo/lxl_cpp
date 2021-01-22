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
        self.node_map = {}
        self.work_dir = ""
        self.auth_pwd = ""
        self.thread_num = 3
        self.cnn_timeout_ms = 3000
        self.cmd_timeout_ms = 3000


def gen_setting(parse_ret):
    ret = RedisClusterSetting()
    cluster_dir = cal_path_redis_cluster_dir(parse_ret)
    ret.work_dir = cluster_dir
    ret.auth_pwd = "xiaolzz"
    ret.thread_num = 3
    ret.cnn_timeout_ms = 3000
    ret.cmd_timeout_ms = 3000

    begin_port = 7000
    for i in range(0, 6):
        port = begin_port + i
        node = RedisNodeSetting()
        node.name = "redis_{}".format(port)
        node.dir = cluster_dir
        node.port = port
        node.client_ip = "127.0.0.1"
        node.peer_ip = "127.0.0.1"
        node.pid_file = "{}/pid_file{}.log".format(node.dir, node.name)
        node.log_file = "{}/log_file_{}.log".format(node.dir, node.name)
        node.cluster_config_file = "{}/config_{}.log".format(node.dir, node.name)
        node.db_file_name = "{}/data_base_{}.log".format(node.dir, node.name)
        node.append_file_name = "{}/data_base_append_{}.log".format(node.dir, node.name)
        ret.node_map[node.name] = node
    return ret

