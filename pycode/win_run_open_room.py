from run_service import *
import multiprocessing
import shlex
import atexit
import time
import sys
import threading
import signal

class _ProcessData(object):
    def __init__(self):
        self.cmd = ""
        self.thread = None
        self.is_exit = False
        self.main_logic = None
        self.return_code = None
        self.error_msg = None


def thread_main_logic(pd):
    ret, rsh = RunServiceHelp.run_service(shlex.split(pd.cmd))
    if 0 != ret:
        pd.return_code = ret
        pd.error_msg = rsh
        print("thread_main_logic run service fail: ret_code:{}, error_msg:{}".format(ret, rsh))
        return ret
    pd.main_logic = rsh
    while not pd.is_exit and rsh.is_running:
        time.sleep(0.1)
    rsh.terminate()
    time.sleep(1)
    pd.return_code = rsh.return_code
    return pd.return_code


def cleanup_process_datas(process_datas):
    for pd in process_datas:
        if not pd.thread.is_alive():
            print(" '{}' exit with code:{}".format(pd.cmd, pd.return_code))
            continue
        else:
            if pd.main_logic:
                pd.main_logic.terminate()
            if pd.thread:
                pd.is_exit = True
        pd.thread.join(timeout=3)


exit_progress = False


def signal_handler(sig_num, handler):
    global exit_progress
    exit_progress = True
    print("!!!!!! signal_handler sig_num:{}".format(sig_num))


for sig_num in [signal.SIGINT, signal.SIGTERM]:
    signal.signal(sig_num, signal_handler)


run_cmds = [
    r"E:\git\ws\lxl_cpp\Debug\service.exe platform E:\git\code\lxl_cpp  E:\git\ws\lxl_cpp\platform",
    r"E:\git\ws\lxl_cpp\Debug\service.exe auth E:\git\code\lxl_cpp  E:\git\ws\lxl_cpp\auth"
]
process_datas = list()
for cmd_str in run_cmds:
    pd = _ProcessData()
    pd.cmd = cmd_str.replace("\\", "/")
    pd.thread = threading.Thread(target=thread_main_logic, args=(pd,), name="run_open_room", daemon=True)
    process_datas.append(pd)
    pd.thread.start()

while not exit_progress:
    is_one_exit = False
    for pd in process_datas:
        if not pd.thread.is_alive():
            is_one_exit = True
        else:
            time.sleep(0.1)
    if is_one_exit:
        break
cleanup_process_datas(process_datas)
process_datas = list()
sys.stdout.flush()
sys.stderr.flush()
sys.exit(0)



