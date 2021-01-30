import auto_gen
import os
import config
import stat


class ServerHelper(object):
    def __init__(self, parse_ret, setting):
        self.parse_ret = parse_ret
        self.setting = setting

    def get_exe_file(self):
        if config.is_win_platform():
            return os.path.join(self.parse_ret.exe_dir, "service.exe")
        else:
            return os.path.join(self.parse_ret.exe_dir, "service")

    def get_exe_dir(self):
        return self.parse_ret.exe_dir

    def get_work_dir(self):
        return config.cal_path_zone_server_dir(self.parse_ret, self.get_name())

    def get_game_config(self):
        return os.path.join(self.get_work_dir(), "game_config.xml")

    def get_hotfix_dir(self):
        return os.path.join(self.get_work_dir(), "hotfix_dir")

    def get_data_dir(self):
        return os.path.join(self.parse_ret.code_dir, "datas")

    def get_lua_script(self):
        return os.path.join(self.parse_ret.code_dir, "lua_script")

    def get_role(self):
        return self.setting.role

    def get_name(self):
        return self.setting.name

    def setup_cmds(self):
        if config.is_win_platform():
            self.setup_win_cmds()
        else:
            self.setup_linux_cmds()

    def setup_win_cmds(self):
        run_cmd = "start cmd /k  {exe_file} {role} {work_dir} {data_dir} {game_config_file} {scrip_dir} \
                --lua_args_begin-- -lua_path . -c_path . {exe_dir} -require_files servers.entrance.server_entrance  -execute_fns start_script"\
            .format_map({
            "exe_file": self.get_exe_file(),
            "role": self.get_role(),
            "work_dir": self.get_work_dir(),
            "data_dir": self.get_data_dir(),
            "game_config_file": self.get_game_config(),
            "scrip_dir": self.get_lua_script(),
            "exe_dir": self.get_exe_dir(),
        })

        config.write_file(os.path.join(self.get_work_dir(), "start.bat"), run_cmd)
        stop_cmd = "taskkill /f /t /im service.exe"
        config.write_file(os.path.join(self.get_work_dir(), "stop.bat"), stop_cmd)
        ps_cmd = """ tasklist /fi "imagename eq service.exe" """
        config.write_file(os.path.join(self.get_work_dir(), "ps.bat"), ps_cmd)

    def setup_linux_cmds(self):
        sh_mod = stat.S_IRWXU | stat.S_IRGRP | stat.S_IWGRP | stat.S_IROTH | stat.S_IWOTH
        
        stop_cmd = """ for pid in `ps -ef | grep '{0}' | grep -v 'grep' | awk '{1}' `; do kill -2 $pid; done """.format(
            self.get_game_config(), "{print $2}")
        stop_sh_path = os.path.join(self.get_work_dir(), "stop.sh")
        config.write_file(stop_sh_path, stop_cmd)
        os.chmod(stop_sh_path, mode=sh_mod)
        ps_cmd = """ ps -ef | grep '{0}' | grep -v 'grep' """.format(self.get_game_config())
        ps_sh_path = os.path.join(self.get_work_dir(), "ps.sh")
        config.write_file(ps_sh_path, ps_cmd)
        os.chmod(ps_sh_path, mode=sh_mod)
        run_cmd = "{exe_file} {role} {work_dir} {data_dir} {game_config_file} {scrip_dir} \
                --lua_args_begin-- -lua_path . -c_path . {exe_dir} \
                -require_files servers.entrance.server_entrance  -execute_fns start_script 2>&1 1>/dev/null &".format_map({
            "exe_file": self.get_exe_file(),
            "role": self.get_role(),
            "work_dir": self.get_work_dir(),
            "data_dir": self.get_data_dir(),
            "game_config_file": self.get_game_config(),
            "scrip_dir": self.get_lua_script(),
            "exe_dir": self.get_exe_dir(),
        })
        run_sh_path = os.path.join(self.get_work_dir(), "start.sh")
        config.write_file(run_sh_path, "{}\n\n{}\n\n{}\n\n".format(stop_cmd, "sleep 1", run_cmd))
        os.chmod(run_sh_path, mode=sh_mod)
        

    def setup_game_config(self):
        is_ok, cfg_content = auto_gen.render("server/server.xml", {
            "node": self.setting
        })
        config.write_file("{}/{}".format(
            config.cal_path_zone_server_dir(self.parse_ret, self.get_name()),"game_config.xml"),
            cfg_content)

    def setup_server(self):
        os.makedirs(self.get_work_dir(), exist_ok=True)
        os.makedirs(self.get_hotfix_dir(), exist_ok=True)
        self.setup_game_config()
        self.setup_cmds()

