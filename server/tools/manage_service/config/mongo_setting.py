from .common import *
import copy


class MongoNodeSetting(object):
    def __init__(self):
        pass


class MongoNodeSetting(object):
    def __init__(self, replica_setting):
        self.replica_setting = replica_setting
        self.port = 0
        self.log_file_path = ""
        self.pid_file_path = ""
        self.db_file_path = ""


class MongoReplicaSetting(object):
    def __init__(self, cluster_setting):
        self.cluster_setting = cluster_setting
        self.name = ""
        self.cluster_role = ""  # shardsvr or configsvr
        self.node_map = {}


class MongoClientSetting(object):
    def __init__(self, cluster_setting):
        self.cluster_setting = cluster_setting
        self.port = 0
        self.log_file_path = ""
        self.pid_file_path = ""


class MongoClusterSetting(object):
    def __init__(self):
        self.work_dir = ""
        self.data_replica_map = {}
        self.cfg_replica = None
        self.client_map = {}
        self.auth_db = ""
        self.auth_user = ""
        self.auth_pwd = ""


def gen_setting(parse_ret):
    ret = MongoClusterSetting()
    next_port = next_num_fn(9000)
    cluster_dir = cal_path_mongo_cluster_dir(parse_ret)
    ret.work_dir = cluster_dir
    ret.auth_db = "admin"
    ret.auth_user = "lxl"
    ret.auth_pwd = "xiaolzz"

    for i in range(0, 2):
        replica = MongoReplicaSetting(ret)
        replica.name = "rs_db_{}".format(i)
        replica.cluster_role = "shardsvr"
        for j in range(0, 2):
            node = MongoNodeSetting(replica)
            node.port = next_port()
            node.log_file_path = "{}/log_file_{}.log".format(cluster_dir, node.port)
            node.pid_file_path = "{}/pid_file_{}.pid".format(cluster_dir, node.port)
            node.db_file_path = "{}/db_file_{}.db".format(cluster_dir, node.port)
            replica.node_map[node.port] = node
        ret.data_replica_map[replica.name] = replica

    ret.cfg_replica = MongoReplicaSetting(ret)
    ret.cfg_replica.name = "rs_cfg"
    ret.cfg_replica.cluster_role = "configsvr"
    for j in range(0, 2):
        node = MongoNodeSetting(ret.cfg_replica)
        node.port = next_port()
        node.log_file_path = "{}/log_file_{}.log".format(cluster_dir, node.port)
        node.pid_file_path = "{}/pid_file_{}.pid".format(cluster_dir, node.port)
        node.db_file_path = "{}/db_file_{}.db".format(cluster_dir, node.port)
        ret.cfg_replica.node_map[node.port] = node

    client_setting = MongoClientSetting(ret)
    client_setting.port = 9400
    client_setting.log_file_path = "{}/log_file_{}.log".format(cluster_dir, client_setting.port)
    client_setting.pid_file_path = "{}/pid_file_{}.pid".format(cluster_dir, client_setting.port)
    ret.client_map[client_setting.port] = client_setting

    return ret




