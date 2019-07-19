
import re
from enum import Enum, IntEnum


class Service_Type(IntEnum):
    platform = 1
    auth = 2
    login = 3
    world = 4
    game = 5
    robot = 6
    gate = 7



def parse_zone_name(zone_name):
    print("parse_zone_name {}".format(zone_name))
    ret = re.match(r"(\S+)_(\d+)", zone_name)
    print("parse_zone_name {0} {1}".format(ret.group(1), ret.group(2)))
    if ret:
        return True, ret.group(1), int(ret.group(2))
    return False, None, None


def cal_zone_name(zone, id):
    return "{0}_{1}".format(zone, id)
