from .common import *
import copy


class EtcdNodeSetting(object):
    def __init__(self):
        self.name = ""
        self.data_dir = ""
        self.log_file = ""
        self.peer_ip = ""
        self.peer_port = 0
        self.client_ip = ""
        self.client_port = 0
        self.cluster_token = ""


class EtcdClusterSetting(object):
    def __init__(self):
        self.node_list = []
        self.cluster_token = ""
        self.work_dir = ""
        self.run_dir = ""
        self.etcd_dirs = []
        self.auth_user = ""
        self.auth_pwd = ""
        self.ttl = 10

    def get_peer_hosts(self):
        str_list = []
        for node in self.node_list:
            str_list.append("{}=http://{}:{}".format(node.name, node.peer_ip, node.peer_port))
        ret = ",".join(str_list)
        return ret

    def get_end_points(self):
        str_list = []
        for node in self.node_list:
            str_list.append("//{}:{}".format(node.client_ip, node.client_port))
        ret = ",".join(str_list)
        return ret

    def get_client_hosts(self):
        str_list = []
        for node in self.node_list:
            str_list.append("http://{}:{}".format(node.client_ip, node.client_port))
        ret = ";".join(str_list)
        return ret


def gen_setting(parse_ret):
    ret = EtcdClusterSetting()
    cluster_dir = cal_path_etcd_cluster_dir(parse_ret)
    run_dir = "{}/run".format(cluster_dir)
    ret.work_dir = cluster_dir
    ret.run_dir = run_dir
    ret.auth_user = "lxl"
    ret.auth_pwd = "xiaolzz"
    ret.etcd_dirs.append("/{}/*".format(parse_ret.zone))
    ret.ttl = 10
    ret.cluster_token = "token_lxl_cpp"

    begin_peer_port = 8101
    begin_client_port = 8100
    port_advance_step = 100

    for i in range(0, 3):
        node = EtcdNodeSetting()
        node.name = "etcd_{}".format(i)
        node.data_dir = "{}/{}".format(run_dir, node.name)
        node.log_file = "{}/{}.log".format(run_dir, node.name)
        node.client_port = begin_client_port + port_advance_step * i
        node.peer_port = begin_peer_port + port_advance_step * i
        node.client_ip = "127.0.0.1"
        node.peer_ip = "127.0.0.1"
        ret.node_list.append(node)
    return ret

