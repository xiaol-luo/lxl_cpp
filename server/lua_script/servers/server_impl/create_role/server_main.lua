

batch_require(require("servers.server_impl.create_role.server_require_files"))

ServiceMgr = CreateRoleServiceMgr

---@class CreateRoleServer : GameServerBase
---@field mongo_setting_uuid MongoServerConfig
---@field mongo_setting_game MongoServerConfig
CreateRoleServer = CreateRoleServer or class("CreateRoleServer", GameServerBase)

function create_server_main(init_setting, init_args)
    return CreateRoleServer:new(init_setting, init_args)
end

function CreateRoleServer:ctor(init_setting, init_args)
    CreateRoleServer.super.ctor(self, Server_Role.Create_Role, init_setting, init_args)
    self.mongo_setting_uuid = nil
    self.mongo_setting_game = nil
end

function CreateRoleServer:_on_init()
    -- mongo的配置:uuid 和game
    for _, v in ipairs(self.init_setting.mongo_service.element) do
        if is_table(v) and v.name == Const.mongo_setting_name_uuid  then
            self.mongo_setting_uuid = MongoServerConfig:new()
            self.mongo_setting_uuid:parse_from(v)
        end
        if is_table(v) and v.name == Const.mongo_setting_name_game  then
            self.mongo_setting_game = MongoServerConfig:new()
            self.mongo_setting_game:parse_from(v)
        end
    end
    if not self.mongo_setting_uuid or not self.mongo_setting_uuid.host then
        return false
    end
    if not self.mongo_setting_game or not self.mongo_setting_game.host then
        return false
    end

    local ret = CreateRoleServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function CreateRoleServer:_on_start()
    local ret = CreateRoleServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function CreateRoleServer:_on_stop()
    CreateRoleServer.super._on_stop(self)
end

function CreateRoleServer:_on_notify_quit_game()
    CreateRoleServer.super._on_notify_quit_game(self)
end

function CreateRoleServer:_check_can_quit_game()
    local can_quit = CreateRoleServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end