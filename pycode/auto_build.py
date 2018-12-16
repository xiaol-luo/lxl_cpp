import argparse
import subprocess
import os
import shlex
# import shutil
import requests

import platform
import codecs

if __name__ != "__main__":
    exit(0)
parser = argparse.ArgumentParser()

# srouce code dir path
parser.add_argument('scdp', help='srouce code dir path')
# lib code dir path
parser.add_argument('lcdp', help='lib code dir path')
# workspace dir path
parser.add_argument('wsdp', help='workspace dir path')

# debug or release
bt_debug = "debug"
bt_release = "release"
parser.add_argument('-bt', '--build_type', choices=[bt_debug, bt_release], default=bt_debug, help='build executable type')

parse_ret = parser.parse_args()

'''
def download_file(file_url, store_path):
    is_ok = True    
    try:
        with requests.get(file_url, stream=True) as r:
            if 200 == r.status_code:    
                with open(store_path, 'wb') as f:
                    r.raw.decode_content = True
                    shutil.copyfileobj(r.raw, f)
    except Exception as e:
        print(e)
        is_ok = False
    return is_ok

import zipfile
def unpack_zip(packed_file, out_dir):
    is_ok = True
    while True:
        if os.path.exists(out_dir) and not os.path.isdir(out_dir):
            is_ok = False
            print("unpack_zip out dir is not a dir: {0}".format(out_dir))
            break
        if not os.path.isfile(packed_file):
            is_ok = False
            print("unpack_zip not exist file: {0} ".format(packed_file))
            break
        os.makedirs(out_dir, exist_ok=True)
        with zipfile.ZipFile(packed_file) as zip_file:
            zip_file.extractall(out_dir)
        break
    return is_ok

lrdb_name = "LRDB"
lrdb_download_url = "https://github.com/satoren/LRDB/archive/master.zip"
lrdb_store_path = "{0}.zip".format(lrdb_name)
lrdb_unpack_dir = lrdb_name
ret = download_file(lrdb_download_url, lrdb_store_path)
if not ret:
    exit(-20)
ret = unpack_zip(lrdb_store_path, lrdb_unpack_dir)
'''

# git lrdb 
class git_project_data(object):
    def __init__(self):
        self.name = None
        self.git_url = None
        self.code_dir = None
        self.ws_dir = None
        self.cmake_dir = None
        self.cmake_params = ""
        self.inc_dirs = ""
        self.lib_dirs = ""
        self.lib_names = None


def quick_create_git_project_data(parse_ret, name, git_url, cmake_dir, cmake_params, inc_dirs, lib_dirs, lib_names):
    ret = git_project_data()
    ret.name = name
    ret.git_url = git_url
    ret.code_dir = os.path.abspath(os.path.join(parse_ret.lcdp, ret.name)).replace('\\', '/')
    ret.ws_dir = os.path.abspath(os.path.join(parse_ret.wsdp, ret.name)).replace('\\', '/')
    if cmake_dir:
        ret.cmake_dir = os.path.abspath(os.path.join(ret.code_dir, cmake_dir)).replace('\\', '/')
    ret.cmake_params = cmake_params
    ret.inc_dirs = inc_dirs
    ret.lib_dirs = lib_dirs
    ret.lib_names = lib_names
    return ret

lrdb_name = "LRDB"
git_project_datas = [
    quick_create_git_project_data(parse_ret, "LRDB",  "https://github.com/satoren/LRDB.git", 
        None, "", [os.path.join(parse_ret.lcdp, "LRDB/include"), 
                    os.path.join(parse_ret.lcdp, "LRDB/third_party/picojson"),
                    os.path.join(parse_ret.lcdp, "LRDB/third_party/asio/asio/include"),], 
        None, None),
    
    quick_create_git_project_data(parse_ret, "behaviac",  "https://github.com/Tencent/behaviac.git", 
        ".", "", [os.path.join(parse_ret.lcdp, "behaviac/inc")], 
        [os.path.join(parse_ret.lcdp, "behaviac/lib")], ["libbehaviac_msvc_debug"]),

    quick_create_git_project_data(parse_ret, "sol2",  "https://github.com/ThePhD/sol2.git", 
        None, "", [os.path.join(parse_ret.lcdp, "sol2/single/sol")], 
        None, None),
    
    quick_create_git_project_data(parse_ret, "Libevent",  "https://github.com/nmathewson/Libevent.git", 
        ".", "-DEVENT__DISABLE_BENCHMARK=ON -DEVENT__DISABLE_OPENSSL=ON", [os.path.join(parse_ret.lcdp, "Libevent/include")],
        [os.path.join(parse_ret.wsdp, "Libevent/lib/Debug")], ["event", "event_core", "event_extra"]),
    
    quick_create_git_project_data(parse_ret, "protobuf",  "https://github.com/google/protobuf.git", 
        "cmake", "-Dprotobuf_WITH_ZLIB=OFF -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_SHARED_LIBS=ON", [os.path.join(parse_ret.lcdp, "protobuf/src")],
        [os.path.join(parse_ret.wsdp, "protobuf/Debug")], ["libprotocd", "libprotobufd", "libprotobuf-lited"]),
]


def is_window_platform():
    return platform.system() == 'Windows'


def shell_cd_cmd(cd_path):
    ret = "cd {}".format(cd_path)
    if os.path.isabs(cd_path) and is_window_platform():
        ret = "{}: && cd {}".format(cd_path[0], cd_path)
    return ret


def handle_git_project(data):
    is_ok = True
    try:
        if os.path.isdir(data.code_dir):
            ret = subprocess.run(shlex.split("{0} && git pull ".format(shell_cd_cmd(data.code_dir))), shell=True)
        else:
            if os.path.exists(data.code_dir) and not os.path.isdir(data.code_dir):
                os.remove(data.code_dir)
            os.makedirs(data.code_dir, exist_ok=True)
            ret = subprocess.run(shlex.split(" git clone {0} {1}".format(data.git_url, data.code_dir)), shell=True)
        if data.cmake_dir:
            os.makedirs(data.ws_dir, exist_ok=True)
            if is_window_platform():
                vstoll_cmd = "{} && VsMSBuildCmd.bat".format(shell_cd_cmd(
                    "d:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/Common7/Tools"))
                cmake_cmd = "{} && {} && cmake {} -G 'Visual Studio 15 2017' {} ".format(
                    vstoll_cmd, shell_cd_cmd(data.ws_dir), data.cmake_params,  data.cmake_dir)
                '''
                vstoll_cmd = "{} && vcvarsall.bat setup_buildsku".format(
                    shell_cd_cmd("D:/Program Files (x86)/Microsoft Visual Studio 14.0/VC"))
                cmake_cmd = "{} && {} && cmake {} -G 'NMake Makefiles' {} && nmake ".format(
                    vstoll_cmd, shell_cd_cmd(data.ws_dir), data.cmake_params,  data.cmake_dir)
                '''
            else:
                cmake_cmd = "cd '{}' && cmake {} && make".format(data.ws_dir, data.cmake_dir)
            ret = subprocess.run(shlex.split(cmake_cmd), shell = True)

    except Exception as e:
        print(e)
        is_ok = False
    else:
        if ret and 0 != ret.returncode:
            print("handle_git_project {} fail, reason {} {} {}".format(
                data.name, ret.returncode, ret.stdout, ret.stderr)) 
            is_ok = False
    return is_ok

all_ok = True
for git_project in git_project_datas:
    all_ok = handle_git_project(git_project)
    if not all_ok:
        continue
        #break
with (codecs.open(os.path.join(parse_ret.scdp, "cmake/Libs.cmake"), 'w', 'utf-8')) as f:
    for git_project in git_project_datas:
        if git_project.inc_dirs:
            for inc_dir in git_project.inc_dirs:
                f.write("INCLUDE_DIRECTORIES({})\n".format(inc_dir).replace('\\', '/'))
        if git_project.lib_dirs:
            for lib_dir in git_project.lib_dirs:
                f.write("LINK_DIRECTORIES({})\n".format(lib_dir).replace('\\', '/'))
        if git_project.lib_names:
            for lib_name in git_project.lib_names:
                f.write("LINK_LIBRARIES({})\n".format(lib_name).replace('\\', '/'))
        f.write("\n")

if not all_ok:
    exit(-10000)




