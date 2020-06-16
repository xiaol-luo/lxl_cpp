
batch_require(require("servers.entrance.common_server_require_files"))
batch_require(require("servers.server_impl.world.server_require_files"))


---@class WorldServer : ServerBase
---@field redis_consistent_hash_setting RedisServerConfig
WorldServer = WorldServer or class("WorldServer", ServerBase)

function create_server_main(init_setting, init_args)
    return WorldServer:new(init_setting, init_args)
end

function WorldServer:ctor(init_setting, init_args)
    WorldServer.super.ctor(self, Server_Role.World, init_setting, init_args)
end

function WorldServer:_on_init()
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