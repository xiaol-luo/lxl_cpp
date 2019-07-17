
import re


def parse_zone_name(zone_name):
    print("parse_zone_name {}".format(zone_name))
    ret = re.match(r"(\S+)_(\d+)", zone_name)
    print("parse_zone_name {0} {1}".format(ret.group(1), ret.group(2)))
    if ret:
        return True, ret.group(1), int(ret.group(2))
    return False, None, None


def cal_zone_name(zone, id):
    return "{0}_{1}".format(zone, id)
