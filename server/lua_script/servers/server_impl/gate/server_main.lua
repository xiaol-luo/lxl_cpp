
batch_require(require("servers.server_impl.gate.server_require_files"))

ServiceMgr = GateServiceMgr

---@class GateServer : ServerBase
---@field redis_setting_online_servers RedisServerConfig
GateServer = GateServer or class("GateServer", ServerBase)

function create_server_main(init_setting, init_args)
    return GateServer:new(init_setting, init_args)
end

function GateServer:ctor(init_setting, init_args)
    GateServer.super.ctor(self, Server_Role.Gate, init_setting, init_args)
end

function GateServer:_on_init()
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

    local ret = GateServer.super._on_init(self)
    if not ret then
        return false
    end

    self.pto_parser:load_files(Login_Pto.pto_files)
    self.pto_parser:setup_id_to_protos(Login_Pto.id_to_pto)
    self.pto_parser:load_files(Forward_Msg_Pto.pto_files)
    self.pto_parser:setup_id_to_protos(Forward_Msg_Pto.id_to_pto)

    return true
end

function GateServer:_on_start()
    local ret = GateServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function GateServer:_on_stop()
    GateServer.super._on_stop(self)
end

function GateServer:_on_notify_quit_game()
    GateServer.super._on_notify_quit_game(self)
end

function GateServer:_check_can_quit_game()
    local can_quit = GateServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end