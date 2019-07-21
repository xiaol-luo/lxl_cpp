from .common import *
import subprocess
import shlex


def ps_zone(parse_ret):
    manage_service_py = cal_zone_manage_service_file_path(parse_ret).replace("\\", "/")
    cmd_str = "{0} {1} ps".format(python_bin(), manage_service_py)
    print("ps_zone cmd_str:{0}".format(cmd_str))
    subprocess.run(shlex.split(cmd_str), shell=True)
    print("ps_zone xxxxxxxxxxxxxxxxxx cmd_str:{0}".format(cmd_str))



