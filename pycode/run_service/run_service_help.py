import os
import argparse
from .define import *


class RunServiceHelp(object):
    def __init__(self, args):
        self.args = vars(args)

    @staticmethod
    def parse_args(input_args):
        parser = argparse.ArgumentParser()
        #parser.add_argument("py_exe")
        parser.add_argument(Const.exe)
        parser.add_argument(Const.role)
        parser.add_argument(Const.code_dir)
        parser.add_argument(Const.work_dir)
        ret_args = parser.parse_args(input_args)
        ret = RunServiceHelp(ret_args)
        is_ok, error_msg = ret.check_valid()
        if not is_ok:
            ret = error_msg
        return is_ok, ret

    @staticmethod
    def run_service(input_args):
        is_ok, rsh= RunServiceHelp.parse_args(input_args)
        if not is_ok:
            return -1, "run service parse_args fail"
        is_ok, error_msg = rsh.prepare_for_run()
        if not is_ok:
            return -2, error_msg
        ret_num, error_msg = rsh.run()
        return ret_num, error_msg

    def check_valid(self):
        for key in [Const.exe, Const.role, Const.work_dir, Const.code_dir]:
            if not self.args[key]:
                return False, "self.args[{}] is None".format(key)
        if not os.path.isfile(self.exe):
            return False, "{} is not a file".format(self.exe)
        if not os.path.isdir(self.code_dir):
            return False, "{} is not a dir".format(self.code_dir)
        if os.path.exists(self.work_dir) and not os.path.isdir(self.work_dir):
            return False, "{} exists, but not a dir".format(self.work_dir)
        return True, None

    def prepare_for_run(self):
        os.makedirs(self.work_dir, exist_ok=True)
        return True, None

    def run(self):
        return 0, None

    @property
    def exe(self):
        return self.args[Const.exe]

    @property
    def role_str(self):
        return self.args[Const.role]

    @property
    def code_dir(self):
        return self.args[Const.code_dir]

    @property
    def work_dir(self):
        return self.args[Const.work_dir]

    def datas_dir(self):
        return os.path.join(self.work_dir, "datas")

    def scripts_dir(self):
        return os.path.join(self.work_dir, "scripts")

    @property
    def role(self):
        str_arr = self.role_str.split('_')
        assert(str_arr and len(str_arr) >= 1)
        return str_arr[0]

    @property
    def role_idx(self):
        str_arr = self.role_str.split('_')
        ret = None
        if str_arr and len(str_arr) >= 2:
            ret = str_arr[2]
        return ret

    @property
    def role_cfg_name(self):
        file_name = "{}.xml".format(self.role)
        if self.role_idx:
            file_name = "{}_{}.xml".format(self.role, self.role_idx)
        return file_name

    @property
    def role_cfg_relate_path(self):
        return os.path.join("setting", self.role_cfg_name)

