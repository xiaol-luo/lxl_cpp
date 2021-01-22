
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



def parse_zone_name(zone_name):
    print("parse_zone_name {}".format(zone_name))
    ret = re.match(r"(\S+)_(\d+)", zone_name)
    print("parse_zone_name {0} {1}".format(ret.group(1), ret.group(2)))
    if ret:
        return True, ret.group(1), int(ret.group(2))
    return False, None, None


def cal_zone_name(zone, id):
    return "{0}_{1}".format(zone, id)


def cal_zone_dir_path(parse_ret):
    return os.path.abspath(os.path.join(parse_ret.work_dir, parse_ret.zone))


def cal_zone_service_dir_path(parse_ret, service_name, idx):
    return os.path.join(cal_zone_dir_path(parse_ret), "{}_{}".format(service_name, idx))


def cal_zone_share_dir_path(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "share")


def cal_zone_setting_dir_path(parse_ret):
    return os.path.join(cal_zone_share_dir_path(parse_ret), "setting")


def cal_zone_all_config_file_path(parse_ret):
    return os.path.join(cal_zone_setting_dir_path(parse_ret), "all_service_config.xml")


def cal_zone_proto_dir_path(parse_ret):
    return os.path.join(cal_zone_share_dir_path(parse_ret), "proto")


def cal_zone_script_dir_path(parse_ret):
    return os.path.join(cal_zone_share_dir_path(parse_ret), "lua_script")


def cal_zone_manage_service_file_path(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "do_manage_service.py")


def cal_path_etcd_cluster_dir(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "etcd_cluster")


def cal_path_redis_cluster_dir(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "redis_cluster")


def cal_path_mongo_cluster_dir(parse_ret):
    return os.path.join(cal_zone_dir_path(parse_ret), "redis_cluster")


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
        with open(file_path, "w") as f:
            f.write(content)


def relink(link_path, real_path, is_dir):
    if os.path.lexists(link_path):
        assert (os.path.islink(link_path))
        os.remove(link_path)
    assert (os.path.lexists(real_path))
    os.symlink(real_path, link_path, is_dir)