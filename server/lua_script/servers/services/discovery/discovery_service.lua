
---@class DiscoveryService: ServiceBase
DiscoveryService = DiscoveryService or class("DiscoveryService", ServiceBase)

function DiscoveryService:ctor(service_mgr, service_name)
    DiscoveryService.super.ctor(self, service_mgr, service_name)

    self._etcd_setting = nil
    self._is_joined_cluster = false

    self._db_path_apply_cluster_id = nil
    self._cluster_id = nil

    self._db_path_zone_server_data = nil
    self._zone_server_json_data = nil
    self._zone_server_data = ZoneServerJsonData:new()

    ---@type EtcdClient
    self._etcd_client = nil
    self._cluster_id_prev_info = nil
    self._is_applying_cluster_id = false

    self._servers_infos = {
        is_watching = false,
        wait_idx = nil,
        server_datas = {},
    }

    self._is_keeping_in_cluster = false
    self._keey_in_cluster_infos = {
        is_keeping = false,
        refresh_ttl_last_sec = 0,
        set_value_last_sec = 0,
    }
end

function DiscoveryService:_on_init()
    DiscoveryService.super._on_init(self)
    self._db_path_watch_server_dir = string.format(Discovery_Service_Const.db_path_format_zone_server_dir, self.server.zone)
    self._db_path_apply_cluster_id = string.format(Discovery_Service_Const.db_path_format_apply_cluster_id, self.server.zone)
    self._db_path_zone_server_data = string.format(Discovery_Service_Const.db_path_format_zone_server_data,
            self.server.zone, self.server.server_role, self.server.server_name)
    self._etcd_setting = self.server.etcd_service_discovery_setting
    self._zone_server_data[ZoneServerJsonDataField.zone] = self.server.zone
    self._zone_server_data[ZoneServerJsonDataField.server_role] = self.server.server_role
    self._zone_server_data[ZoneServerJsonDataField.server_name] = self.server.server_name
    self._zone_server_data[ZoneServerJsonDataField.advertise_client_ip] = self.server.init_setting.advertise_client_ip
    self._zone_server_data[ZoneServerJsonDataField.advertise_client_port] = self.server.init_setting.advertise_client_port
    self._zone_server_data[ZoneServerJsonDataField.advertise_peer_ip] = self.server.init_setting.advertise_peer_ip
    self._zone_server_data[ZoneServerJsonDataField.advertise_peer_port] = self.server.init_setting.advertise_peer_port
    self._zone_server_data[ZoneServerJsonDataField.db_path] = self._db_path_zone_server_data

    self._etcd_client = EtcdClient:new(self._etcd_setting.host, self._etcd_setting.user, self._etcd_setting.pwd)
end

function DiscoveryService:_on_start()
    DiscoveryService.super._on_start(self)
    self._etcd_client:set(self._db_path_watch_server_dir, nil, nil, true)
end

function DiscoveryService:_on_stop()
    DiscoveryService.super._on_stop(self)
end

function DiscoveryService:_on_update()
    DiscoveryService.super._on_update(self)
    self:_try_apply_cluster_id()
    self:_watch_servers_data()
    self:_keep_in_cluster()

end

function DiscoveryService:_try_apply_cluster_id()
    if self._cluster_id then
        return
    end

    if not self._cluster_id_prev_info then
        self._is_applying_cluster_id = true
        self._etcd_client:get(self._db_path_apply_cluster_id, false, function(op_id, op, ret)
            self._is_applying_cluster_id = false
            if ret:is_ok() then
                self._cluster_id_prev_info = {
                    prev_idx = ret.op_result.node.modifiedIndex,
                    prev_value = ret.op_result.node.value
                }
            else
                local Error_Key_Not_Found = 100
                if 0 == ret.fail_code and Error_Key_Not_Found == ret.op_result.errorCode then
                    self._cluster_id_prev_info = {
                        prev_idx = nil,
                        prev_value = nil,
                    }
                end
            end
            print("get cluster_id op ret", op_id, ret)
        end)
        return
    end

    if self._cluster_id_prev_info then
        self._is_applying_cluster_id = true
        local prev_value = self._cluster_id_prev_info.prev_value and tonumber(self._cluster_id_prev_info.prev_value) or 0
        local next_value = 1 +  (prev_value and tonumber(prev_value) or 0)
        self._etcd_client:cmp_swap(self._db_path_apply_cluster_id, self._cluster_id_prev_info.prev_idx,
                prev_value, next_value, function(op_id, op, ret)
                    self._is_applying_cluster_id = false
                    print("set cluster_id op ret",  op_id, self._db_path_apply_cluster_id, ret)
                    if ret:is_ok() then
                        self._cluster_id = ret.op_result.node.value
                        self._zone_server_data[ZoneServerJsonDataField.cluster_id] = self._cluster_id
                        self._zone_server_json_data = self._zone_server_data:to_json()
                    else
                        self._cluster_id_prev_info = nil
                    end
                end)
        return
    end
end

function DiscoveryService:_watch_servers_data()
    if self._servers_infos.is_watching then
        return
    end

    if not self._servers_infos.wait_idx then
        self._servers_infos.is_watching = true
        self._etcd_client:get(self._db_path_watch_server_dir, true, function(op_id, op, ret)
            self._servers_infos.is_watching = false
            if ret:is_ok() then
                self._servers_infos.wait_idx = ret.op_result[Etcd_Const.Head_Index]
            end
            print("DiscoveryService:_watch_servers_data pull ", ret)
        end)
        return
    end

    if self._servers_infos.wait_idx then
        self._servers_infos.is_watching = true
        self._etcd_client:watch(self._db_path_watch_server_dir, true, self._servers_infos.wait_idx, function(op_id, op, ret)
            self._servers_infos.is_watching = false
            print("DiscoveryService:_watch_servers_data watch ", ret)
            if ret:is_ok() then
                self._servers_infos.wait_idx = ret.op_result[Etcd_Const.Head_Index]
            else
                self._servers_infos.wait_idx = nil
            end
        end)
        return
    end
end

function DiscoveryService:_keep_in_cluster()
    if self._keey_in_cluster_infos.is_keeping or not self._cluster_id then
        return
    end
    local now_sec = logic_sec()
    if not self._is_joined_cluster then
        if now_sec - self._keey_in_cluster_infos.set_value_last_sec > 1 then
            self._keey_in_cluster_infos.set_value_last_sec = now_sec
            self._keey_in_cluster_infos.is_keeping = true
            self._etcd_client:cmp_swap(self._db_path_zone_server_data, nil, nil, self._zone_server_json_data, function(op_id, op, ret)
                self._keey_in_cluster_infos.is_keeping = false
                if ret:is_ok() then
                    self._is_joined_cluster = true
                    self._keey_in_cluster_infos.refresh_ttl_last_sec = 0
                    print("DiscoveryService:_keep_in_cluster set", ret)
                end
            end)
        end
    end
    if self._is_joined_cluster then
        if now_sec - self._keey_in_cluster_infos.refresh_ttl_last_sec > 3 then
            self._keey_in_cluster_infos.refresh_ttl_last_sec = now_sec
            self._keey_in_cluster_infos.is_keeping = true
            self._etcd_client:refresh_ttl(self._db_path_zone_server_data, 6, false, function(op_id, op, ret)
                self._keey_in_cluster_infos.is_keeping = false
                if ret:is_ok() then
                else
                    self._is_joined_cluster = false
                end
                print("DiscoveryService:_keep_in_cluster refresh ttl", ret)
            end)
        end
    end
end

function DiscoveryService:_check_is_joined_cluster()

end

