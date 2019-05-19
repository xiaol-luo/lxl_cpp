from run_service import *
import sys
import multiprocessing
import subprocess
import typing
import shlex
import atexit
import time


class _ProcessData(object):
    def __init__(self):
        cmd = ""
        thread = None


def thread_main_logic(pd):
    print("thread_main_logic run:{}".format(pd.cmd))
    ret, error_msg = RunServiceHelp.run_service(shlex.split(pd.cmd))
    return ret and 0 or -1


def at_exit_clean_process_datas(process_datas):
    def clean_fn():
        for pd in process_datas:
            if pd.thread.is_alive():
                pd.thread.terminate()
    return clean_fn


if __name__ == "__main__":
    ret, error_msg = RunServiceHelp.run_service(sys.argv[1:])
    if 0 != ret:
        print(error_msg)
        sys.exit(Const.exit_error)
    run_cmds = [
        r"E:\ws\lxl_cpp\Debug\service.exe platform E:\github\lxl_cpp  E:\ws\lxl_cpp\platform",
        r"E:\ws\lxl_cpp\Debug\service.exe auth E:\github\lxl_cpp  E:\ws\lxl_cpp\auth"
    ]
    process_datas = list()
    atexit.register(at_exit_clean_process_datas(process_datas))
    for cmd_str in run_cmds:
        pd = _ProcessData()
        pd.cmd = cmd_str.replace("\\", "/")
        pd.thread = multiprocessing.Process(target=thread_main_logic, args=(pd,))
        process_datas.append(pd)
        pd.thread.start()

    while True:
        for pd in process_datas:
            if not pd.thread.is_alive():
                print(" '{}' exit with code:{}".format(pd.cmd, pd.thread.exitcode or "None"))
                sys.exit(-1)
            else:
                time.sleep(0.1)

