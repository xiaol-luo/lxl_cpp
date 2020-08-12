

batch_require(require("servers.server_impl.world_sentinel.server_require_files"))

ServiceMgr = WorldSentinelServiceMgr

---@class WorldSentinelServer : GameServerBase
---@field redis_setting_work_servers RedisServerConfig
WorldSentinelServer = WorldSentinelServer or class("WorldSentinelServer", GameServerBase)

function create_server_main(init_setting, init_args)
    return WorldSentinelServer:new(init_setting, init_args)
end

function WorldSentinelServer:ctor(init_setting, init_args)
    WorldSentinelServer.super.ctor(self, Server_Role.World_Sentinel, init_setting, init_args)
end

function WorldSentinelServer:_on_init()
    -- 一致性哈希使用redis server的配置
    for _, v in ipairs(self.init_setting.redis_service.element) do
        if is_table(v) and v.name == Const.redis_setting_name_work_servers  then
            self.redis_setting_work_servers = RedisServerConfig:new()
            self.redis_setting_work_servers:parse_from(v)
        end
    end
    if not self.redis_setting_work_servers or not self.redis_setting_work_servers.host then
        return false
    end

    local ret = WorldSentinelServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function WorldSentinelServer:_on_start()
    local ret = WorldSentinelServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function WorldSentinelServer:_on_stop()
    WorldSentinelServer.super._on_stop(self)
end

function WorldSentinelServer:_on_notify_quit_game()
    WorldSentinelServer.super._on_notify_quit_game(self)
end

function WorldSentinelServer:_check_can_quit_game()
    local can_quit = WorldSentinelServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end