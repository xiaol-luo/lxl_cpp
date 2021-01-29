
import re
from enum import Enum, IntEnum
import os
import platform


class Service_Type(IntEnum):
    platform = 1
    auth = 2
    login = 3
    world = 4
    game = 5
    robot = 6
    gate = 7
    match = 8
    fight = 9
    room = 10
    create_role = 11
    world_sentinel = 12


def parse_zone_name(zone_name):
    print("parse_zone_name {}".format(zone_name))
    ret = re.match(r"(\S+)_(\d+)", zone_name)
    print("parse_zone_name {0} {1}".format(ret.group(1), ret.group(2)))
    if ret:
        return True, ret.group(1), int(ret.group(2))
    return False, None, None


def cal_zone_name(zone, id):
    return "{0}_{1}".format(zone, id)


def fix_path(path_val):
    return path_val.replace("\\", "/")

def cal_zone_dir_path(parse_ret):
    return os.path.abspath(os.path.join(parse_ret.work_dir, parse_ret.zone)).replace("\\", "/")


def cal_zone_service_dir_path(parse_ret, service_name, idx):
    return os.path.join(cal_zone_dir_path(parse_ret), "{}_{}".format(service_name, idx)).replace("\\", "/")


def cal_path_zone_server_root_dir(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "servers").replace("\\", "/")


def cal_path_zone_server_dir(parse_ret, server_name):
    return os.path.join(cal_path_zone_server_root_dir(parse_ret), server_name).replace("\\", "/")




def cal_zone_share_dir_path(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "share").replace("\\", "/")


def cal_zone_setting_dir_path(parse_ret):
    return os.path.join(cal_zone_share_dir_path(parse_ret), "setting").replace("\\", "/")


def cal_zone_all_config_file_path(parse_ret):
    return os.path.join(cal_zone_setting_dir_path(parse_ret), "all_service_config.xml").replace("\\", "/")


def cal_zone_proto_dir_path(parse_ret):
    return os.path.join(cal_zone_share_dir_path(parse_ret), "proto").replace("\\", "/")


def cal_zone_script_dir_path(parse_ret):
    return os.path.join(cal_zone_share_dir_path(parse_ret), "lua_script").replace("\\", "/")


def cal_zone_manage_service_file_path(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "do_manage_service.py").replace("\\", "/")


def cal_path_etcd_cluster_dir(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "etcd_cluster").replace("\\", "/")


def cal_path_redis_cluster_dir(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "redis_cluster").replace("\\", "/")


def cal_path_mongo_cluster_dir(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "mongo_cluster").replace("\\", "/")


def is_win_platform():
    return platform.system() == 'Windows'


def python_bin():
    if is_win_platform():
        return "python"
    else:
        return "python3"


def next_num_fn(next_num):
    def _do_gen():
        nonlocal next_num
        next_num = next_num + 1
        return next_num
    return _do_gen


def write_file(file_path, content):
    if content is not None:
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "w") as f:
            f.write(content)


def relink(link_path, real_path, is_dir):
    if os.path.lexists(link_path):
        assert (os.path.islink(link_path))
        os.remove(link_path)
    assert (os.path.lexists(real_path))
    os.makedirs(os.path.dirname(real_path), exist_ok=True)
    # os.symlink(real_path, link_path, is_dir)