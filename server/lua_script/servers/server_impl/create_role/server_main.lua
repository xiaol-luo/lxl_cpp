
batch_require(require("servers.entrance.common_server_require_files"))
batch_require(require("servers.server_impl.create_role.server_require_files"))


---@class CreateRoleServer : ServerBase
---@field redis_online_servers_setting RedisServerConfig
CreateRoleServer = CreateRoleServer or class("CreateRoleServer", ServerBase)

function create_server_main(init_setting, init_args)
    return CreateRoleServer:new(init_setting, init_args)
end

function CreateRoleServer:ctor(init_setting, init_args)
    CreateRoleServer.super.ctor(self, Server_Role.Create_Role, init_setting, init_args)
end

function CreateRoleServer:_on_init()
    ---- 一致性哈希使用redis server的配置
    --for _, v in ipairs(self.init_setting.redis_service.element) do
    --    if is_table(v) and v.name == Const.online_servers  then
    --        self.redis_online_servers_setting = RedisServerConfig:new()
    --        self.redis_online_servers_setting:parse_from(v)
    --    end
    --end
    --if not self.redis_online_servers_setting or not self.redis_online_servers_setting.host then
    --    return false
    --end

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