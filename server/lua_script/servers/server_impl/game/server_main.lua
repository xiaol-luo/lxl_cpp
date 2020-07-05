

batch_require(require("servers.server_impl.game.server_require_files"))


---@class GameServer : ServerBase
---@field redis_setting_online_servers RedisServerConfig
---@field mongo_setting_game MongoServerConfig
GameServer = GameServer or class("GameServer", ServerBase)

function create_server_main(init_setting, init_args)
    return GameServer:new(init_setting, init_args)
end

function GameServer:ctor(init_setting, init_args)
    GameServer.super.ctor(self, Server_Role.Game, init_setting, init_args)
end

function GameServer:_on_init()
    -- 一致性哈希使用redis server的配置
    for _, v in ipairs(self.init_setting.redis_service.element) do
        if is_table(v) and v.name == Const.redis_setting_name_online_servers  then
            self.redis_setting_online_servers = RedisServerConfig:new()
            self.redis_setting_online_servers:parse_from(v)
        end
    end
    if not self.redis_setting_online_servers or not self.redis_setting_online_servers.host then
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

    local ret = GameServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function GameServer:_on_start()
    local ret = GameServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function GameServer:_on_stop()
    GameServer.super._on_stop(self)
end

function GameServer:_on_notify_quit_game()
    GameServer.super._on_notify_quit_game(self)
end

function GameServer:_check_can_quit_game()
    local can_quit = GameServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end