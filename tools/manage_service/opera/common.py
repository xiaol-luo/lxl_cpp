
import os


def cal_zone_dir_path(parse_ret):
    return os.path.join(parse_ret.work_dir, parse_ret.zone)


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


