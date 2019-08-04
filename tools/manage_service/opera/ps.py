from .common import *
import subprocess
import shlex


def ps_zone(parse_ret):
    manage_service_py = cal_zone_manage_service_file_path(parse_ret).replace("\\", "/")
    cmd_str = "{0} {1} ps".format(python_bin(), manage_service_py)
    if parse_ret.role:
        cmd_str = "{0} --role {1}".format(cmd_str, parse_ret.role)
    subprocess.run(cmd_str, shell=True)



