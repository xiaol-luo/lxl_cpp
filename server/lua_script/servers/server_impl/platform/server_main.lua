
-- batch_require(require("servers.server_impl.platform.server_require_files"))
include_file("servers.server_impl.platform.include")
ServiceMgr = PlatformServiceMgr

---@class PlatformServer : ServiceBase
---@field mongo_setting MongoServerConfig
---@field http_net HttpNetService
PlatformServer = PlatformServer or class("PlatformServer", ServerBase)

function create_server_main(init_setting, init_args)
    return PlatformServer:new(init_setting, init_args)
end

function PlatformServer:ctor(init_setting, init_args)
    PlatformServer.super.ctor(self, Server_Role.Platform, init_setting, init_args)
    self.pto_parser = ProtoParser:new()
end

function PlatformServer:_on_init()
    local ret = PlatformServer.super._on_init(self)
    if not ret then
        return false
    end

    -- mongo的配置:platform
    local xml_mongo_element = xml.extract_element(self.init_setting.mongo_service.element, "name", Const.mongo_setting_name_platform)
    if xml_mongo_element then
        self.mongo_setting = MongoServerConfig:new()
        self.mongo_setting:parse_from(xml_mongo_element)
    end
    if not self.mongo_setting or not self.mongo_setting.host then
        return false
    end

    self.pto_parser:add_search_dirs({ path.combine(self.init_args[Const.main_args_data_dir], "proto")  })
    self.pto_parser:load_files(Login_Pto.pto_files)
    self.pto_parser:setup_id_to_protos(Login_Pto.id_to_pto)

    return true
end

function PlatformServer:_on_start()
    local ret = PlatformServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function PlatformServer:_on_stop()
    PlatformServer.super._on_stop(self)
end

function PlatformServer:_on_notify_quit_game()
    PlatformServer.super._on_notify_quit_game(self)
end

function PlatformServer:_check_can_quit_game()
    local can_quit = PlatformServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end