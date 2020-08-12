
---@class GameServerBase : ServerBase
---@field init_args table<string, string>
---@field init_setting table<string, string>
---@field server_role Server_Role
---@field server_name string
---@field etcd_service_discovery_setting EtcdServerConfig
---@field pto_parser ProtoParser
---@field discovery DiscoveryService
---@field peer_net PeerNetService
---@field zone_name string
---@field zone_setting ZoneSettingService
---@field rpc RpcService
---@field join_cluster JoinClusterService
GameServerBase = GameServerBase or class("GameServerBase", ServerBase)

function GameServerBase:ctor(server_role, init_setting, init_args)
    GameServerBase.super.ctor(self, server_role, init_setting, init_args)
    self.zone_name = nil
    self.server_name = nil
    self.etcd_service_discovery_setting = nil
    ---@type Server_Quit_State
    self.pto_parser = ProtoParser:new()
end

function GameServerBase:_on_init()
    if not GameServerBase.super._on_init() then
        return false
    end

    self.pto_parser:add_search_dirs({ path.combine(self.init_args[Const.main_args_data_dir], "proto")  })

    if self.server_role ~= string.lower(self.init_setting.server_role) then
        log_error("GameServerBase:_on_init server_role=%s, but init_setting.server_role=%s, mismatch!", self.server_role, self.init_setting.server_role)
        return false
    end

    if not self.init_setting.zone then
        return false
    end
    self.zone_name = string.lower(self.init_setting.zone)

    if not self.init_setting.server_name then
        return false
    end
    self.server_name = string.lower(self.init_setting.server_name)

    for _, v in ipairs(self.init_setting.etcd_server.element) do
        if is_table(v) and v.name == Const.service_discovery  then

            self.etcd_service_discovery_setting = EtcdServerConfig:new()
            self.etcd_service_discovery_setting:parse_from(v)
        end
    end
    if not self.etcd_service_discovery_setting or not self.etcd_service_discovery_setting.host then
        return false
    end

    return true
end

function GameServerBase:_set_as_field(field_name, obj)
    if obj then
        assert(not self[field_name])
        self[field_name] = obj
    end
end

function GameServerBase:get_cluster_server_key()
    return self.join_cluster:get_server_key()
end

function GameServerBase:get_cluster_server_id()
    return self.join_cluster:get_cluster_server_id()
end

function GameServerBase:is_joined_cluster()
    return self.join_cluster:is_joined_cluster()
end

function GameServerBase:get_cluster_server_data()
    return self.join_cluster:get_server_data()
end

function GameServerBase:get_cluster_server_data_str()
    return self.join_cluster:get_server_data_json_str()
end

function GameServerBase:get_cluster_server_name()
    return self.join_cluster:get_cluster_server_name()
end

function GameServerBase:get_zone_name()
    return self.zone_name
end

function GameServerBase:get_server_role()
    return self.server_role
end

function GameServerBase:get_server_name()
    return self.server_name
end
