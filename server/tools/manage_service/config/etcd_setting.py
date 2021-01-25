from .common import *
import copy


class EtcdNodeSetting(object):
    def __init__(self):
        self.name = ""
        self.data_dir = ""
        self.peer_ip = ""
        self.peer_port = 0
        self.client_ip = ""
        self.client_port = 0
        self.cluster_token = ""


class EtcdClusterSetting(object):
    def __init__(self):
        self.node_map = {}
        self.cluster_token = ""
        self.work_dir = ""
        self.auth_user = ""
        self.auth_pwd = ""
        self.ttl = 10

    def get_peer_hosts(self):
        str_list = []
        for node in self.node_map.values():
            str_list.append("{}=http://{}:{}".format(node.name, node.peer_ip, node.peer_port))
        ret = ",".join(str_list)
        return ret


def gen_setting(parse_ret):
    ret = EtcdClusterSetting()
    cluster_dir = cal_path_etcd_cluster_dir(parse_ret)
    ret.work_dir = cluster_dir
    ret.auth_user = "root"
    ret.auth_pwd = "xiaolzz"
    ret.ttl = 10
    ret.cluster_token = "token_lxl_cpp"

    begin_peer_port = 8101
    begin_client_port = 8100
    port_advance_step = 100

    for i in range(0, 3):
        node = EtcdNodeSetting()
        node.name = "etcd_{}".format(i)
        node.data_dir = "{}/{}".format(cluster_dir, node.name)
        node.client_port = begin_client_port + port_advance_step * i
        node.peer_port = begin_peer_port + port_advance_step * i
        node.client_ip = "127.0.0.1"
        node.peer_ip = "127.0.0.1"
        ret.node_map[node.name] = node
    return ret

