import auto_gen
import platform
import os
from .common import *
import config
import stat


class ServiceHelper(object):
    def __init__(self, role, parse_ret, setting):
        self.role = role
        self.parse_ret = parse_ret
        self.setting = setting

    @property
    def run_setting_file(self):
        return "run_setting.xml"

    @property
    def bin_dir(self):
        return "bin"

    @property
    def bin_file_name(self):
        if config.is_win_platform():
            return "service.exe"
        else:
            return "service"

    @property
    def config_name(self):
        return "{0}_service".format(self.role)

    @property
    def datas_dir(self):
        return "datas"

    @property
    def setting_dir(self):
        return "setting"

    @property
    def script_dir(self):
        return "lua_script"

    @property
    def proto_dir(self):
        return "proto"

    def setup_cmds(self, params):
        if config.is_win_platform():
            self.setup_win_cmds(params)
        else:
            self.setup_linux_cmds(params)

    def setup_win_cmds(self, params):
        run_cmd = "start cmd /c {0} {1} {2} {3} {4} {5} --lua_args_begin-- -lua_path . -c_path . {6} -require_files services.main  -execute_fns start_script".format(
            params["bin_file"],
            params["role"],
            params["service_dir"],
            params["datas_dir"],
            params["run_setting_file"],
            params["script_dir"],
            params["bin_dir"]
        )
        config.write_file(os.path.join(params["service_dir"], "run.bat"), run_cmd)
        stop_cmd = "taskkill /f /t /im service.exe"
        config.write_file(os.path.join(params["service_dir"], "stop.bat"), stop_cmd)
        ps_cmd = """ tasklist /fi "imagename eq service.exe" """
        config.write_file(os.path.join(params["service_dir"], "ps.bat"), ps_cmd)

    def setup_linux_cmds(self, params):
        run_cmd = "{0} {1} {2} {3} {4} {5} --lua_args_begin-- -lua_path . -c_path . {6} -require_files services.main  -execute_fns start_script 2>&1 1>/dev/null &".format(
            params["bin_file"],
            params["role"],
            params["service_dir"],
            params["datas_dir"],
            params["run_setting_file"],
            params["script_dir"],
            params["bin_dir"]
        )
        sh_mod = stat.S_IRWXU | stat.S_IRGRP | stat.S_IWGRP | stat.S_IROTH | stat.S_IWOTH
        run_sh_path = os.path.join(params["service_dir"], "run.sh")
        config.write_file(run_sh_path, run_cmd)
        os.chmod(run_sh_path, mode=sh_mod)
        stop_cmd = """ for pid in `ps -ef | grep '{0}' | grep -v 'grep' | awk '{1}' `; do kill -9 $pid; done """.format(
            params["bin_file"], "{print $2}")
        stop_sh_path = os.path.join(params["service_dir"], "stop.sh")
        config.write_file(stop_sh_path, stop_cmd)
        os.chmod(stop_sh_path, mode=sh_mod)
        ps_cmd = """ ps -ef | grep '{0}' | grep -v 'grep' """.format(params["bin_file"])
        ps_sh_path = os.path.join(params["service_dir"], "ps.sh")
        config.write_file(ps_sh_path, ps_cmd)
        os.chmod(ps_sh_path, mode=sh_mod)

    def setup_services(self):
        for i, cfg in enumerate(self.setting[self.config_name]):
            idx = cfg.get("idx", i)
            service_dir = config.cal_zone_service_dir_path(self.parse_ret, self.role, idx)
            os.makedirs(service_dir, exist_ok=True)
            datas_dir = os.path.join(service_dir, self.datas_dir)
            os.makedirs(datas_dir, exist_ok=True)
            setting_dir = os.path.join(datas_dir, self.setting_dir)
            config.relink(setting_dir, config.cal_zone_setting_dir_path(self.parse_ret), True)
            script_dir = os.path.join(service_dir, self.script_dir)
            config.relink(script_dir, config.cal_zone_script_dir_path(self.parse_ret), True)
            proto_dir = os.path.join(datas_dir, self.proto_dir)
            config.relink(proto_dir, config.cal_zone_proto_dir_path(self.parse_ret), True)
            setting_tt_path = "service_setting/{0}.xml".format(self.role)
            ret, setting_content = auto_gen.render(setting_tt_path, cfg)
            assert (ret)
            run_setting_file = os.path.join(datas_dir, self.run_setting_file)
            config.write_file(run_setting_file, setting_content)
            bin_dir = os.path.join(service_dir, self.bin_dir)
            config.relink(bin_dir, self.parse_ret.exe_dir, True)
            cmd_params = {
                "service_dir": service_dir,
                "bin_dir": os.path.abspath(bin_dir).replace("\\", "/"),
                "bin_file": os.path.abspath(os.path.join(bin_dir, self.bin_file_name)).replace("\\", "/"),
                "role": self.role,
                "datas_dir": os.path.abspath(datas_dir).replace("\\", "/"),
                "run_setting_file": os.path.join(self.run_setting_file).replace("\\", "/"),
                "script_dir": os.path.abspath(script_dir).replace("\\", "/"),
            }
            self.setup_cmds(cmd_params)
            print(cfg)

    def extract_info(self):
        ret = []
        for i, cfg in enumerate(self.setting[self.config_name]):
            idx = cfg.get("idx", i)
            service_dir = os.path.abspath(
                config.cal_zone_service_dir_path(self.parse_ret, self.role, idx)).replace("\\", "/")
            ret.append({
                "role": cfg["role"],
                "idx": idx,
                "service_dir": service_dir
            })
        return ret


def create_etcd_cluster(parse_ret):
    cluster_setting = config.gen_etcd_setting(parse_ret)
    for node in cluster_setting.node_list:
        is_ok, ret_txt = auto_gen.render("etcd/etcd.conf", {
            "node": node,
            "cluster": cluster_setting,
        })
        ret_file_path = os.path.join(cluster_setting.work_dir, node.name)
        config.write_file(ret_file_path, ret_txt)
        print(ret_txt)
    is_ok, cfg_content = auto_gen.render("etcd/start_all.sh", {
        "cluster": cluster_setting,
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "start_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("etcd/stop_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "stop_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("etcd/ps_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "ps_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("etcd/clear_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "clear_all.sh"), cfg_content)


def create_redis_cluster(parse_ret):
    cluster_setting = config.gen_redis_setting(parse_ret)
    for node in cluster_setting.node_list:
        is_ok, ret_txt = auto_gen.render("redis/redis.conf", {
            "node": node,
            "cluster": cluster_setting,
        })
        ret_file_path = os.path.join(cluster_setting.work_dir, node.name)
        config.write_file(ret_file_path, ret_txt)
    is_ok, cfg_content = auto_gen.render("redis/start_all.sh", {
        "cluster": cluster_setting,
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "start_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("redis/stop_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "stop_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("redis/ps_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "ps_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("redis/clear_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "clear_all.sh"), cfg_content)


def create_mongo_cluster(parse_ret):
    cluster_setting = config.gen_mongo_setting(parse_ret)
    for node in cluster_setting.cfg_replica.node_list:
        is_ok, cfg_content = auto_gen.render("mongo/mongod.conf", {
            "node": node,
            "cluster": cluster_setting,
            "replica": cluster_setting.cfg_replica,
        })
        config.write_file("{}/{}".format(cluster_setting.work_dir, node.name), cfg_content)
    for replica in cluster_setting.data_replica_list:
        for node in replica.node_list:
            is_ok, cfg_content = auto_gen.render("mongo/mongod.conf", {
                "node": node,
                "cluster": cluster_setting,
                "replica": replica,
            })
            config.write_file("{}/{}".format(cluster_setting.work_dir, node.name), cfg_content)
    for node in cluster_setting.client_list:
        is_ok, cfg_content = auto_gen.render("mongo/mongos.conf", {
            "node": node,
            "cluster": cluster_setting,
        })
        config.write_file("{}/{}".format(cluster_setting.work_dir, node.name), cfg_content)

    is_ok, cfg_content = auto_gen.render("mongo/start_all.sh", {
        "client": cluster_setting.get_prefer_client(),
        "cluster": cluster_setting,
        "user": "lxl",
        "pwd": "xiaolzz",
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "start_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("mongo/stop_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "stop_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("mongo/ps_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "ps_all.sh"), cfg_content)
    is_ok, cfg_content = auto_gen.render("mongo/clear_all.sh", {
        "cluster": cluster_setting
    })
    config.write_file("{}/{}".format(cluster_setting.work_dir, "clear_all.sh"), cfg_content)


def create_game_server(parse_ret):
    pass


def create_zone(parse_ret):
    # os.makedirs(config.cal_zone_dir_path(parse_ret), exist_ok=True)

    # os.makedirs(os.path.dirname(config.cal_zone_script_dir_path(parse_ret)), exist_ok=True)
    # config.relink(config.cal_zone_script_dir_path(parse_ret), os.path.join(parse_ret.code_dir, "lua_script"), True)

    # os.makedirs(os.path.dirname(config.cal_zone_proto_dir_path(parse_ret)), exist_ok=True)
    # config.relink(config.cal_zone_proto_dir_path(parse_ret), os.path.join(parse_ret.code_dir, "datas/proto"), True)

    create_etcd_cluster(parse_ret)
    create_redis_cluster(parse_ret)
    create_mongo_cluster(parse_ret)
    # create_game_server(parse_ret)

