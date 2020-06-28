
batch_require(require("servers.entrance.common_server_require_files"))
batch_require(require("servers.server_impl.game.server_require_files"))


---@class GameServer : ServerBase
---@field redis_online_servers_setting RedisServerConfig
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
        if is_table(v) and v.name == Const.online_servers  then
            self.redis_online_servers_setting = RedisServerConfig:new()
            self.redis_online_servers_setting:parse_from(v)
        end
    end
    if not self.redis_online_servers_setting or not self.redis_online_servers_setting.host then
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