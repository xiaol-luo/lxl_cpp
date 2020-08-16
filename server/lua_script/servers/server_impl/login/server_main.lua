
batch_require(require("servers.server_impl.login.server_require_files"))

ServiceMgr = LoginServiceMgr

---@class LoginServer : ServiceBase
---@field mongo_setting_login MongoServerConfig
LoginServer = LoginServer or class("LoginServer", ServerBase)

function create_server_main(init_setting, init_args)
    return LoginServer:new(init_setting, init_args)
end

function LoginServer:ctor(init_setting, init_args)
    LoginServer.super.ctor(self, Server_Role.Login, init_setting, init_args)
    self.pto_parser = ProtoParser:new()
end

function LoginServer:_on_init()
    local ret = LoginServer.super._on_init(self)
    if not ret then
        return false
    end

    -- mongo的配置:login
    local xml_mongo_element = xml.extract_element(self.init_setting.mongo_service.element, "name", Const.mongo_setting_name_login)
    if xml_mongo_element then
        self.mongo_setting_login = MongoServerConfig:new()
        self.mongo_setting_login:parse_from(xml_mongo_element)
    end
    if not self.mongo_setting_login or not self.mongo_setting_login.host then
        return false
    end

    self.pto_parser:add_search_dirs({ path.combine(self.init_args[Const.main_args_data_dir], "proto")  })
    self.pto_parser:load_files(Login_Pto.pto_files)
    self.pto_parser:setup_id_to_protos(Login_Pto.id_to_pto)

    return true
end

function LoginServer:_on_start()
    local ret = LoginServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function LoginServer:_on_stop()
    LoginServer.super._on_stop(self)
end

function LoginServer:_on_notify_quit_game()
    LoginServer.super._on_notify_quit_game(self)
end

function LoginServer:_check_can_quit_game()
    local can_quit = LoginServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end