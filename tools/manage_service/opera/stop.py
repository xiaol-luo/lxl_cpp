from .common import *
import subprocess
import shlex


def stop_zone(parse_ret):
    manage_service_py = cal_zone_manage_service_file_path(parse_ret).replace("\\", "/")
    cmd_str = "python {0} stop".format(manage_service_py)
    subprocess.run(shlex.split(cmd_str), shell=True)




