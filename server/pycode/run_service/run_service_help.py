import os
import argparse
from .define import *
import subprocess
import shlex


class RunServiceHelp(object):
    def __init__(self, args):
        self.args = vars(args)
        self.process = None
        self.is_runned = False

    @staticmethod
    def parse_args(input_args):
        parser = argparse.ArgumentParser()
        # parser.add_argument("py_exe")
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
            return -1, "run service parse_args fail" + rsh
        ret_num, error_msg = rsh.run()
        if 0 != ret_num:
            return ret_num, error_msg
        return 0, rsh

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
        self.is_runned = True
        is_ok, error_msg = self.prepare_for_run()
        if not is_ok:
            return -2, error_msg
        run_cmd = "{} {} {} {} {} {} --lua_args_begin-- -lua_path . -c_path . {} -require_files servers.entrance.main  -execute_fns start_script".format(
            self.exe,
            self.role,
            self.work_dir,
            self.datas_dir(),
            self.role_cfg_relate_path,
            self.scripts_dir(),
            self.exe_dir
        )
        print("run cmd: " + run_cmd)
        try:
            self.process = subprocess.Popen(
                shlex.split(run_cmd),
                # stderr=subprocess.PIPE,
                # stdout=subprocess.PIPE,
                # creationflags=subprocess.CREATE_NEW_CONSOLE,
                shell=True
            )
        except Exception as e:
            return -3, str(e)
        # self.process.poll()
        return 0, None

    @property
    def is_running(self):
        if not self.is_runned:
            return False
        if not self.process:
            return False
        if None != self.process.returncode:
            return False
        self.process.poll()
        return True

    @property
    def return_code(self):
        if not self.is_runned:
            return None
        if None == self.process:
            return -1
        self.process.poll()
        return self.process.returncode

    def send_signal(self, signal):
        if self.is_runned and self.process:
            self.process.send_signal(signal)

    def terminate(self):
        if self.is_runned and self.process:
            self.process.terminate()

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
        return os.path.join(self.code_dir, "datas").replace("\\", "/")

    def scripts_dir(self):
        return os.path.join(self.code_dir, "lua_script").replace("\\", "/")

    @property
    def role(self):
        str_arr = self.role_str.split('_')
        assert(str_arr and len(str_arr) > 0)
        str_arr.pop()
        ret = str.join("_", str_arr)
        return ret

    @property
    def role_idx(self):
        str_arr = self.role_str.split('_')
        ret = None
        if str_arr and len(str_arr) > 1:
            ret = str_arr[len(str_arr) - 1]
        return ret

    @property
    def role_cfg_name(self):
        file_name = "{}.xml".format(self.role)
        if self.role_idx:
            file_name = "{}_{}.xml".format(self.role, self.role_idx)
        return file_name

    @property
    def exe_dir(self):
        return os.path.dirname(self.exe)

    @property
    def role_cfg_relate_path(self):
        return os.path.join("setting", self.role_cfg_name).replace("\\", "/")

