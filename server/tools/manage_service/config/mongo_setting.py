from .common import *
import copy


class MongoNodeSetting(object):
    def __init__(self, replica_setting):
        self.replica_setting = replica_setting
        self.name = ""
        self.port = 0
        self.log_file_path = ""
        self.pid_file_path = ""
        self.db_file_path = ""
        self.peer_ip = "127.0.0.1"
        self.client_ip = "127.0.0.1"


class MongoReplicaSetting(object):
    def __init__(self, cluster_setting):
        self.cluster_setting = cluster_setting
        self.name = ""
        self.cluster_role = ""  # shardsvr or configsvr
        self.node_list = []

    def get_rs_init_raw_cmd(self):
        node_str_list = []
        for i in range(0, len(self.node_list)):
            node = self.node_list[i]
            node_str_list.append("{{_id:{}, host:\"{}:{}\"}}".format(i, node.peer_ip, node.port))
        cmd_str = "rs.initiate({{ _id:\"{}\", members:[ {} ] }}); rs.slaveOk()".format(self.name, ",".join(node_str_list))
        return cmd_str

    def get_rs_init_cmd(self):
        cmd_str = self.get_rs_init_raw_cmd()
        ret = "mongo -port {} -eval '{}'".format(self.node_list[0].port, cmd_str)
        return ret

    def get_rs_add_shard_raw_cmd(self):
        node_str_list = []
        for i in range(0, len(self.node_list)):
            node = self.node_list[i]
            node_str_list.append("{}:{}".format(node.peer_ip, node.port))
        cmd_str = "sh.addShard(\"{}/{}\")".format(self.name, ",".join(node_str_list))
        return cmd_str


class MongoClientSetting(object):
    def __init__(self, cluster_setting):
        self.cluster_setting = cluster_setting
        self.name = ""
        self.port = 0
        self.log_file_path = ""
        self.pid_file_path = ""


class MongoShardSetting(object):
    def __init__(self):
        self.db = ""
        self.coll = ""
        self.field = ""
        self.unique = False


class MongoClusterSetting(object):
    def __init__(self):
        self.work_dir = ""
        self.data_replica_list = []
        self.cfg_replica = None
        self.client_list = []
        self.auth_db = ""
        self.auth_user = ""
        self.auth_pwd = ""
        self.shard_list = []

    def get_sharding_config_db(self):
        ret_list = []
        for node in self.cfg_replica.node_list:
            ret_list.append("{}:{}".format(node.peer_ip, node.port))
        ret = "{}/{}".format(self.cfg_replica.name, ",".join(ret_list))
        return ret

    def get_prefer_client(self):
        return self.client_list[0]

    def get_shard_dbs(self):
        db_map = {}
        for elem in self.shard_list:
            db_map[elem.db] = True
        return db_map.keys()


def gen_setting(parse_ret):
    ret = MongoClusterSetting()
    next_port = next_num_fn(9000)
    cluster_dir = cal_path_mongo_cluster_dir(parse_ret)
    run_dir = "{}/{}".format(cluster_dir, "run")
    ret.work_dir = cluster_dir
    ret.run_dir = run_dir
    ret.auth_db = "admin"
    ret.auth_user = "lxl"
    ret.auth_pwd = "xiaolzz"

    for i in range(0, 3):
        replica = MongoReplicaSetting(ret)
        replica.name = "rs_db_{}".format(i)
        replica.cluster_role = "shardsvr"
        for j in range(0, 3):
            node = MongoNodeSetting(replica)
            node.port = next_port()
            node.name = "{}_{}".format(replica.name, node.port)
            node.log_file_path = "{}/log_file_{}.log".format(run_dir, node.port)
            node.pid_file_path = "{}/pid_file_{}.pid".format(run_dir, node.port)
            node.db_file_path = "{}/db_file_{}".format(run_dir, node.port)
            replica.node_list.append(node)
        ret.data_replica_list.append(replica)

    ret.cfg_replica = MongoReplicaSetting(ret)
    ret.cfg_replica.name = "rs_cfg"
    ret.cfg_replica.cluster_role = "configsvr"
    for j in range(0, 3):
        node = MongoNodeSetting(ret.cfg_replica)
        node.port = next_port()
        node.name = "{}_{}".format(ret.cfg_replica.name, node.port)
        node.log_file_path = "{}/log_file_{}.log".format(run_dir, node.port)
        node.pid_file_path = "{}/pid_file_{}.pid".format(run_dir, node.port)
        node.db_file_path = "{}/db_file_{}".format(run_dir, node.port)
        node.peer_ip = "127.0.0.1"
        node.client_ip = "127.0.0.1"
        ret.cfg_replica.node_list.append(node)

    client_setting = MongoClientSetting(ret)
    client_setting.port = 9400
    client_setting.name = "mongos_{}".format(client_setting.port)
    client_setting.log_file_path = "{}/mongos_log_file_{}.log".format(run_dir, client_setting.port)
    client_setting.pid_file_path = "{}/mongos_pid_file_{}.pid".format(run_dir, client_setting.port)
    ret.client_list.append(client_setting)

    # shard game_zone_x.role.[role_id]
    shard_setting = MongoShardSetting()
    shard_setting.db = "game_{}".format(parse_ret.zone)
    shard_setting.coll = "role"
    shard_setting.fields = ["role_id"]
    shard_setting.unique = True
    ret.shard_list.append(shard_setting)

    # shard login_zone_x.account.[account_id]
    shard_setting = MongoShardSetting()
    shard_setting.db = "login_{}".format(parse_ret.zone)
    shard_setting.coll = "account"
    shard_setting.field = "account_id"
    shard_setting.unique = True
    ret.shard_list.append(shard_setting)

    return ret




