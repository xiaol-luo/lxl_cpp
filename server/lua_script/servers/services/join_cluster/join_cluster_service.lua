
---@class JoinClusterService: ServiceBase
JoinClusterService = JoinClusterService or class("JoinClusterService", ServiceBase)

function JoinClusterService:ctor(service_mgr, service_name)
    JoinClusterService.super.ctor(self, service_mgr, service_name)

    ---@type EtcdClient
    self._etcd_client = nil

    self._is_joined_cluster = false

    -- 申请集群唯一的id：cluster_server_id
    self._db_path_apply_cluster_id = nil
    self._cluster_server_id = nil
    self._cluster_server_id_prev_info = nil
    self._is_applying_cluster_server_id = false
    self._apply_cluster_server_id_last_sec = 0

    -- 把self._zone_server_data_json_str设置到etcd的路径self._db_path_zone_server_data
    -- 如果设置成功，表示竞争到加入集群的锁（权力）
    self._db_path_zone_server_data = nil
    self._zone_server_data_json_str = nil
    self._zone_server_data = ZoneServerJsonData:new()
    self._keep_in_cluster_infos = {
        is_keeping = false,
        refresh_ttl_last_sec = 0,
        set_value_last_sec = 0,
        create_index = nil,
        modified_index = nil,
    }

    ---@type ZoneSettingService
    self._zone_setting = nil
    self._is_allow_join_cluster = false
    self._cluster_server_name = nil
end

function JoinClusterService:_on_init()
    JoinClusterService.super._on_init(self)
    self._db_path_apply_cluster_id = string.format(Join_Cluster_Service_Const.db_path_format_apply_cluster_id, self.server.zone_name)
    self._db_path_zone_server_data = string.format(Join_Cluster_Service_Const.db_path_format_zone_server_data,
            self.server.zone_name, self.server.server_role, self.server.server_name)

    self._zone_server_data[ZoneServerJsonDataField.zone] = self.server.zone_name
    self._zone_server_data[ZoneServerJsonDataField.server_role] = self.server.server_role
    self._zone_server_data[ZoneServerJsonDataField.server_name] = self.server.server_name
    self._zone_server_data[ZoneServerJsonDataField.advertise_client_ip] = self.server.init_setting.advertise_client_ip
    self._zone_server_data[ZoneServerJsonDataField.advertise_client_port] = self.server.init_setting.advertise_client_port
    self._zone_server_data[ZoneServerJsonDataField.advertise_peer_ip] = self.server.init_setting.advertise_peer_ip
    self._zone_server_data[ZoneServerJsonDataField.advertise_peer_port] = self.server.init_setting.advertise_peer_port
    self._zone_server_data[ZoneServerJsonDataField.db_path] = self._db_path_zone_server_data

    local etcd_setting = self.server.etcd_service_discovery_setting
    self._etcd_client = EtcdClient:new(etcd_setting.host, etcd_setting.user, etcd_setting.pwd)
    self._zone_setting = self.server.zone_setting

    self._cluster_server_name = gen_cluster_server_name(self.server.server_role, self.server.server_name)
end

function JoinClusterService:_on_start()
    JoinClusterService.super._on_start(self)
    self._is_allow_join_cluster = self._zone_setting:is_server_allow_join(self._cluster_server_name)
    self._event_binder:bind(self._zone_setting, Zone_Setting_Event.zone_setting_allow_join_servers_diff,
            Functional.make_closure(self._on_event_zone_setting_allow_join_servers_diff, self))
end

function JoinClusterService:_on_stop()
    JoinClusterService.super._on_stop(self)
end

function JoinClusterService:_on_update()
    JoinClusterService.super._on_update(self)

    self:_try_apply_cluster_server_id()
    self:_keep_in_cluster()
end

function JoinClusterService:_try_apply_cluster_server_id()
    if self._cluster_server_id then
        return
    end
    local now_sec = logic_sec()
    if now_sec - self._apply_cluster_server_id_last_sec < 1 then
        return
    end
    self._apply_cluster_server_id_last_sec = now_sec

    -- 先获取最新的cluster_server_id，然后通过cmp_swap的方式来保证得到的cluster_server_id是唯一的
    if not self._cluster_server_id_prev_info then
        self._is_applying_cluster_server_id = true
        self._etcd_client:get(self._db_path_apply_cluster_id, false, function(op_id, op, ret)
            self._is_applying_cluster_server_id = false
            if ret:is_ok() then
                self._cluster_server_id_prev_info = {
                    prev_idx = ret.op_result.node.modifiedIndex,
                    prev_value = ret.op_result.node.value
                }
            else
                local Error_Key_Not_Found = 100
                if 0 == ret.fail_code and Error_Key_Not_Found == ret.op_result.errorCode then
                    self._cluster_server_id_prev_info = {
                        prev_idx = nil,
                        prev_value = nil,
                    }
                end
                if ret:fail_msg() then
                    log_warn("JoinClusterService:_try_apply_cluster_server_id get fail, because %s", ret:fail_msg())
                end
            end
            -- log_print("get cluster_id op ret", op_id, ret)
        end)
        return
    end

    if self._cluster_server_id_prev_info then
        self._is_applying_cluster_server_id = true
        local prev_value = self._cluster_server_id_prev_info.prev_value and tonumber(self._cluster_server_id_prev_info.prev_value) or 0
        local next_value = 1 +  (prev_value and tonumber(prev_value) or 0)
        self._etcd_client:cmp_swap(self._db_path_apply_cluster_id, self._cluster_server_id_prev_info.prev_idx,
                prev_value, next_value, nil, function(op_id, op, ret)
                    self._is_applying_cluster_server_id = false
                    -- log_print("set cluster_id op ret",  op_id, self._db_path_apply_cluster_id, ret)
                    if ret:is_ok() then
                        self._cluster_server_id = ret.op_result.node.value
                        self._zone_server_data[ZoneServerJsonDataField.cluster_server_id] = self._cluster_server_id
                        self._zone_server_data_json_str = self._zone_server_data:to_json()
                    else
                        self._cluster_server_id_prev_info = nil
                    end
                    if ret:fail_msg() then
                        log_warn("JoinClusterService apply cluster id ret=%s, fail_msg=%s", ret:is_ok(), ret:fail_msg())
                    else
                        log_info("JoinClusterService apply cluster id ret=%s", ret:is_ok())
                    end
                end)
        return
    end
end

function JoinClusterService:_keep_in_cluster()
    if self._keep_in_cluster_infos.is_keeping or not self._cluster_server_id then
        return
    end
    if not self._is_allow_join_cluster or not self._zone_setting:is_ready() then
        return
    end

    local now_sec = logic_sec()
    if not self._is_joined_cluster then
        if now_sec - self._keep_in_cluster_infos.set_value_last_sec >= Join_Cluster_Service_Const.refresh_ttl_sec / 4.0 then
            self._keep_in_cluster_infos.set_value_last_sec = now_sec
            self._keep_in_cluster_infos.is_keeping = true
            self._etcd_client:cmp_swap(self._db_path_zone_server_data, nil, nil, self._zone_server_data_json_str, Join_Cluster_Service_Const.refresh_ttl_sec, function(op_id, op, ret)
                self._keep_in_cluster_infos.is_keeping = false
                -- log_print("DiscoveryService:_keep_in_cluster set", ret:is_ok())
                if ret:is_ok() then
                    self:_set_join_cluster(true)
                    self._keep_in_cluster_infos.create_index = ret.op_result.node.createdIndex
                    self._keep_in_cluster_infos.modified_index = ret.op_result.node.modifiedIndex
                    self._keep_in_cluster_infos.refresh_ttl_last_sec = 0
                else
                    self:_set_join_cluster(false)
                end
            end)
        end
    end
    if self._is_joined_cluster then
        if now_sec - self._keep_in_cluster_infos.refresh_ttl_last_sec >= Join_Cluster_Service_Const.refresh_ttl_sec / 2.0 then
            self._keep_in_cluster_infos.refresh_ttl_last_sec = now_sec
            self._keep_in_cluster_infos.is_keeping = true
            self._etcd_client:refresh_ttl(self._db_path_zone_server_data, Join_Cluster_Service_Const.refresh_ttl_sec, false, function(op_id, op, ret)
                self._keep_in_cluster_infos.is_keeping = false
                -- log_print("DiscoveryService:_keep_in_cluster refresh ttl", ret:is_ok())
                if ret:is_ok() then
                    self._keep_in_cluster_infos.modified_index = ret.op_result.node.modifiedIndex
                    if ret.op_result.node.createdIndex ~= self._keep_in_cluster_infos.create_index then
                        self:_set_join_cluster(false)
                    end
                else
                    self:_set_join_cluster(false)
                end
            end)
        end
    end
end

function JoinClusterService:_on_event_zone_setting_allow_join_servers_diff(key, diff_type, value)
    local old_value = self._is_allow_join_cluster
    self._is_allow_join_cluster = self._zone_setting:is_server_allow_join(self._cluster_server_name)
    if old_value and old_value ~= self._is_allow_join_cluster then
        if self._is_joined_cluster then
            if self._keep_in_cluster_infos.modified_index then
                self._etcd_client:cmp_delete(self._db_path_zone_server_data, self._keep_in_cluster_infos.modified_index,
                        self._zone_server_data_json_str, false)
                self:_set_join_cluster(false)
            end
        end
    end
end

function JoinClusterService:_set_join_cluster(is_joined)
    local is_change = self._is_joined_cluster ~= is_joined
    self._is_joined_cluster = is_joined
    if not self._is_joined_cluster then
        self._keep_in_cluster_infos.create_index = nil
    end
    if is_change then
        log_print("JoinClusterService:_set_join_cluster ", is_joined)
        self.server:fire(Join_Cluster_Service_Event.cluster_join_state_change, self._is_joined_cluster)
    end
end

function JoinClusterService:is_joined_cluster()
    return self._is_joined_cluster
end

function JoinClusterService:get_cluster_server_id()
    return self._cluster_server_id
end

function JoinClusterService:get_server_key()
    return self._db_path_zone_server_data
end

function JoinClusterService:get_cluster_server_name()
    return self._cluster_server_name
end

---@return ZoneServerJsonData
function JoinClusterService:get_server_data()
    return self._zone_server_data
end

function JoinClusterService:get_server_data_json_str()
    return self._zone_server_data_json_str
end


