

batch_require(require("servers.server_impl.world.server_require_files"))

ServiceMgr = WorldServiceMgr

---@class WorldServer : ServerBase
---@field redis_setting_work_servers RedisServerConfig
---@field mongo_setting_game MongoServerConfig
---@field work_world_shadow ServerRoleShadow
WorldServer = WorldServer or class("WorldServer", ServerBase)

function create_server_main(init_setting, init_args)
    return WorldServer:new(init_setting, init_args)
end

function WorldServer:ctor(init_setting, init_args)
    WorldServer.super.ctor(self, Server_Role.World, init_setting, init_args)
    self.redis_setting_work_servers = nil
    self.mongo_setting_game = nil
end

function WorldServer:_on_init()
    -- 一致性哈希使用redis server的配置
    for _, v in ipairs(self.init_setting.redis_service.element) do
        if is_table(v) and v.name == Const.redis_setting_name_work_servers then
            self.redis_setting_work_servers = RedisServerConfig:new()
            self.redis_setting_work_servers:parse_from(v)
        end
    end
    if not self.redis_setting_work_servers or not self.redis_setting_work_servers.host then
        return false
    end

    -- mongo的配置:game
    for _, v in ipairs(self.init_setting.mongo_service.element) do
        if is_table(v) and v.name == Const.mongo_setting_name_game  then
            self.mongo_setting_game = MongoServerConfig:new()
            self.mongo_setting_game:parse_from(v)
        end
    end
    if not self.mongo_setting_game or not self.mongo_setting_game.host then
        return false
    end

    local ret = WorldServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function WorldServer:_on_start()
    local ret = WorldServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function WorldServer:_on_stop()
    WorldServer.super._on_stop(self)
end

function WorldServer:_on_notify_quit_game()
    WorldServer.super._on_notify_quit_game(self)
end

function WorldServer:_check_can_quit_game()
    local can_quit = WorldServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end