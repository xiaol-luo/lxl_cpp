
batch_require(require("servers.server_impl.auth.server_require_files"))

ServiceMgr = AuthServiceMgr

---@class AuthServer : ServiceBase
---@field mongo_setting_auth MongoServerConfig
---@field mongo_setting_uuid MongoServerConfig
---@field db_uuid DBUuidService
AuthServer = AuthServer or class("AuthServer", ServerBase)

function create_server_main(init_setting, init_args)
    return AuthServer:new(init_setting, init_args)
end

function AuthServer:ctor(init_setting, init_args)
    AuthServer.super.ctor(self, Server_Role.Auth, init_setting, init_args)
    self.mongo_setting_auth = nil
    self.mongo_setting_uuid = nil
end

function AuthServer:_on_init()
    local ret = AuthServer.super._on_init(self)
    if not ret then
        return false
    end

    do
        -- mongo的配置:auth
        local xml_mongo_element = xml.extract_element(self.init_setting.mongo_service.element, "name", Const.mongo_setting_name_auth)
        local mongo_setting = nil
        if xml_mongo_element then
            mongo_setting = MongoServerConfig:new()
            mongo_setting:parse_from(xml_mongo_element)
        end
        if not mongo_setting or not mongo_setting.host then
            return false
        end
        self.mongo_setting_auth = mongo_setting
    end
    do
        -- mongo的配置:uuid
        local xml_mongo_element = xml.extract_element(self.init_setting.mongo_service.element, "name", Const.mongo_setting_name_uuid)
        local mongo_setting = nil
        if xml_mongo_element then
            mongo_setting = MongoServerConfig:new()
            mongo_setting:parse_from(xml_mongo_element)
        end
        if not mongo_setting or not mongo_setting.host then
            return false
        end
        self.mongo_setting_uuid = mongo_setting
    end

    return true
end

function AuthServer:_on_start()
    local ret = AuthServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function AuthServer:_on_stop()
    AuthServer.super._on_stop(self)
end

function AuthServer:_on_notify_quit_game()
    AuthServer.super._on_notify_quit_game(self)
end

function AuthServer:_check_can_quit_game()
    local can_quit = AuthServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end