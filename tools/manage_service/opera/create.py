import auto_gen
import platform
from .common import *
import config


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
        if is_win_platform():
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
        if is_win_platform():
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
        write_file(os.path.join(params["service_dir"], "run.bat"), run_cmd)
        stop_cmd = "taskkill /f /t /im service.exe"
        write_file(os.path.join(params["service_dir"], "stop.bat"), stop_cmd)
        ps_cmd = """ tasklist /fi "imagename eq service.exe" """
        write_file(os.path.join(params["service_dir"], "ps.bat"), ps_cmd)


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
        write_file(os.path.join(params["service_dir"], "run.sh"), run_cmd)
        stop_cmd = """ ps -ef | grep '{0}' | grep -v 'grep' """.format(params["bin_file"])
        stop_cmd = stop_cmd + "| awk '{print $2}' | xargs kill -9 "
        write_file(os.path.join(params["service_dir"], "stop.sh"), stop_cmd)
        ps_cmd = """ ps -ef | grep '{0}' | grep -v 'grep' """.format(params["bin_file"])
        write_file(os.path.join(params["service_dir"], "ps.sh"), ps_cmd)


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
            service_dir = os.path.abspath(cal_zone_service_dir_path(self.parse_ret, self.role, idx)).replace("\\", "/")
            ret.append({
                "role": cfg["role"],
                "idx": idx,
                "service_dir": service_dir
            })
        return ret



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

    service_helps = {
        config.Service_Type.platform: ServiceHelper("platform", parse_ret, setting),
        config.Service_Type.auth: ServiceHelper("auth", parse_ret, setting),
        config.Service_Type.login: ServiceHelper("login", parse_ret, setting),
        config.Service_Type.gate: ServiceHelper("gate", parse_ret, setting),
        config.Service_Type.world: ServiceHelper("world", parse_ret, setting),
        config.Service_Type.game: ServiceHelper("game", parse_ret, setting),
        config.Service_Type.robot: ServiceHelper("robot", parse_ret, setting),
    }
    service_Infos = []
    for service_type, service_data in service_helps.items():
        service_data.setup_services()
        service_Infos.extend(service_data.extract_info())
    render_ret, render_content = auto_gen.render("service_setting/do_manage_service.txt", service_Infos=service_Infos)
    assert(render_ret)
    write_file(cal_zone_manage_service_file_path(parse_ret), render_content)
    print(service_Infos)



def __execute2(parse_ret):
    print("opera create execute2")
    pass
