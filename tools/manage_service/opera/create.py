import auto_gen
import config
import os
import config
from .common import *


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
        return "service.exe"

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

    @property
    def run_script_file(self):
        return "run.bat"

    def setup_services(self):
        for i, cfg in enumerate(self.setting[self.config_name]):
            idx = cfg.get("idx", i)
            service_dir = cal_zone_service_dir_path(self.parse_ret, self.role, idx)
            os.makedirs(service_dir, exist_ok=True)
            datas_dir = os.path.join(service_dir, self.datas_dir)
            os.makedirs(datas_dir, exist_ok=True)
            setting_dir = os.path.join(datas_dir, self.setting_dir)
            relink(setting_dir, cal_zone_setting_dir_path(self.parse_ret), True)
            script_dir = os.path.join(service_dir, self.script_dir)
            relink(script_dir, cal_zone_script_dir_path(self.parse_ret), True)
            proto_dir = os.path.join(datas_dir, self.proto_dir)
            relink(proto_dir, cal_zone_proto_dir_path(self.parse_ret), True)
            setting_tt_path = "service_setting/{0}.xml".format(self.role)
            ret, setting_content = auto_gen.render(setting_tt_path, cfg)
            assert(ret)
            run_setting_file = os.path.join(datas_dir, self.run_setting_file)
            write_file(run_setting_file, setting_content)
            bin_dir = os.path.join(service_dir, self.bin_dir)
            relink(bin_dir, self.parse_ret.exe_dir, True)
            run_cmd_bin_dir = os.path.abspath(os.path.join(bin_dir, self.bin_file_name)).replace("\\", "/")
            run_cmd = "{0} {1} {2} {3} {4} {5} --lua_args_begin-- -lua_path . -c_path . {6} -require_files services.main  -execute_fns start_script".format(
                run_cmd_bin_dir,
                self.role,
                os.path.abspath(service_dir).replace("\\", "/"),
                os.path.abspath(datas_dir).replace("\\", "/"),
                os.path.join(self.run_setting_file).replace("\\", "/"),
                os.path.abspath(script_dir).replace("\\", "/"),
                run_cmd_bin_dir
            )
            write_file(os.path.join(service_dir, self.run_script_file), run_cmd)
            print(cfg)


def write_file(file_path, content):
    if content is not None:
        with open(file_path, "w") as f:
            f.write(content)


def relink(link_path, real_path, is_dir):
    if os.path.lexists(link_path):
        assert(os.path.islink(link_path))
        os.remove(link_path)
    assert(os.path.lexists(real_path))
    os.symlink(real_path, link_path, is_dir)



def create_zone(parse_ret):
    zone_dir = cal_zone_dir_path(parse_ret)
    os.makedirs(zone_dir, exist_ok=True)
    zone_share_dir = cal_zone_share_dir_path(parse_ret)
    os.makedirs(zone_share_dir, exist_ok=True)
    setting_dir = cal_zone_setting_dir_path(parse_ret)
    os.makedirs(setting_dir, exist_ok=True)
    setting = config.get_service_setting(parse_ret.zone)
    print(setting)
    tt_all_service_config = auto_gen.get_template("service_setting/all_service_config.xml")
    print(tt_all_service_config.render(setting))
    write_file(cal_zone_all_config_file_path(parse_ret), tt_all_service_config.render(setting))
    relink(cal_zone_script_dir_path(parse_ret), os.path.join(parse_ret.code_dir, "lua_script"), True)
    relink(cal_zone_proto_dir_path(parse_ret), os.path.join(parse_ret.code_dir, "datas/proto"), True)

    service_datas = {
        config.Service_Type.platform: ServiceHelper("platform", parse_ret, setting),
        config.Service_Type.auth: ServiceHelper("auth", parse_ret, setting),
        config.Service_Type.login: ServiceHelper("login", parse_ret, setting),
        config.Service_Type.gate: ServiceHelper("gate", parse_ret, setting),
        config.Service_Type.world: ServiceHelper("world", parse_ret, setting),
        config.Service_Type.game: ServiceHelper("game", parse_ret, setting),
        config.Service_Type.robot: ServiceHelper("robot", parse_ret, setting),
    }
    for service_type, service_data in service_datas.items():
        service_data.setup_services()


def __execute2(parse_ret):
    print("opera create execute2")
    pass
