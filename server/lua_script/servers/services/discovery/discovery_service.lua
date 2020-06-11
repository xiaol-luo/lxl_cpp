
---@class DiscoveryService: ServiceBase
DiscoveryService = DiscoveryService or class("DiscoveryService", ServiceBase)

function DiscoveryService:ctor(service_mgr, service_name)
    DiscoveryService.super.ctor(self, service_mgr, service_name)

    self._etcd_setting = nil
    self._is_joined_cluster = false

    self._db_path_apply_cluster_id = nil
    self._cluster_server_id = nil

    self._db_path_zone_server_data = nil
    self._zone_server_data_json_str = nil
    self._zone_server_data = ZoneServerJsonData:new()

    ---@type EtcdClient
    self._etcd_client = nil
    self._cluster_id_prev_info = nil
    self._is_applying_cluster_id = false
    self._apply_cluster_id_last_sec = 0

    self._servers_infos = {
        is_watching = false,
        wait_idx = nil,
        ---@type table<string, ZoneServerJsonData>
        server_datas = {},
    }

    self._is_keeping_in_cluster = false
    self._keey_in_cluster_infos = {
        is_keeping = false,
        refresh_ttl_last_sec = 0,
        set_value_last_sec = 0,
        create_index = nil,
    }

    ---@type ZoneSettingService
    self._zone_setting = nil

    self._is_allow_join_cluster = false
    self._cluster_server_name = nil
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
    self._zone_setting = self.server.zone_setting
    self._cluster_server_name = gen_cluster_server_name(self.server.server_role, self.server.server_name)
end

function DiscoveryService:_on_start()
    DiscoveryService.super._on_start(self)
    self._etcd_client:set(self._db_path_watch_server_dir, nil, nil, true)
    self._is_allow_join_cluster = self._zone_setting:is_server_allow_join(self._cluster_server_name)
    self._event_binder:bind(self._zone_setting, Zone_Setting_Event.zone_setting_allow_join_servers_diff,
            Functional.make_closure(self._on_event_zone_setting_allow_join_servers_diff, self))
end

function DiscoveryService:_on_stop()
    DiscoveryService.super._on_stop(self)
end

function DiscoveryService:_on_update()
    DiscoveryService.super._on_update(self)
    self:_try_apply_cluster_server_id()
    self:_watch_servers_data()
    self:_keep_in_cluster()
end

function DiscoveryService:_try_apply_cluster_server_id()
    if self._cluster_server_id then
        return
    end
    local now_sec = logic_sec()
    if now_sec - self._apply_cluster_id_last_sec < 1 then
        return
    end
    self._apply_cluster_id_last_sec = now_sec

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
            -- log_print("get cluster_id op ret", op_id, ret)
        end)
        return
    end

    if self._cluster_id_prev_info then
        self._is_applying_cluster_id = true
        local prev_value = self._cluster_id_prev_info.prev_value and tonumber(self._cluster_id_prev_info.prev_value) or 0
        local next_value = 1 +  (prev_value and tonumber(prev_value) or 0)
        self._etcd_client:cmp_swap(self._db_path_apply_cluster_id, self._cluster_id_prev_info.prev_idx,
                prev_value, next_value, nil, function(op_id, op, ret)
                    self._is_applying_cluster_id = false
                    -- log_print("set cluster_id op ret",  op_id, self._db_path_apply_cluster_id, ret)
                    if ret:is_ok() then
                        self._cluster_server_id = ret.op_result.node.value
                        self._zone_server_data[ZoneServerJsonDataField.cluster_server_id] = self._cluster_server_id
                        self._zone_server_data_json_str = self._zone_server_data:to_json()
                    else
                        self._cluster_id_prev_info = nil
                    end
                    log_info("DiscoveryService apply cluster id ret=%s, fail_msg=%s", ret:is_ok(), ret:fail_msg())
                end)
        return
    end
end

function DiscoveryService:_watch_servers_data()
    if self._servers_infos.is_watching then
        return
    end
    if not self._zone_setting:is_ready() then
        return
    end

    if not self._servers_infos.wait_idx then
        self._servers_infos.is_watching = true
        self._etcd_client:get(self._db_path_watch_server_dir, true, function(op_id, op, ret)
            self._servers_infos.is_watching = false
            if ret:is_ok() then
                self._servers_infos.wait_idx = tonumber(ret.op_result[Etcd_Const.Head_Index]) + 1
                self:_process_servers_pull_ret(ret)
            end
            -- log_print("DiscoveryService:_watch_servers_data pull ", ret)
        end)
        return
    end

    if self._servers_infos.wait_idx then
        self._servers_infos.is_watching = true
        self._etcd_client:watch(self._db_path_watch_server_dir, true, self._servers_infos.wait_idx, function(op_id, op, ret)
            self._servers_infos.is_watching = false
            -- log_print("DiscoveryService:_watch_servers_data watch ", ret)
            if ret:is_ok() then
                self._servers_infos.wait_idx = tonumber(ret.op_result.node.modifiedIndex) + 1
                self:_process_servers_watch_ret(ret)
            else
                self._servers_infos.wait_idx = nil
            end
        end)
        return
    end
end


---@return ZoneServerJsonData
function DiscoveryService:_create_server_data(node)
    local server_data = nil
    if not node.dir then
        local data = ZoneServerJsonData:new():from_json(node.value)
        server_data = DiscoveryServerData:new()
        server_data.key = node.key
        server_data.value = node.value
        server_data.create_index = node.createdIndex
        server_data.modified_index = node.modifiedIndex
        server_data.data = data
    end
    return server_data
end

function DiscoveryService:_process_servers_pull_ret(etcd_ret)
    if not etcd_ret:is_ok() or not etcd_ret.op_result.node.dir then
        return
    end

    local old_server_datas = self._servers_infos.server_datas
    local new_server_datas = {}
    for _, v in pairs(etcd_ret.op_result.node.nodes or {}) do
        local server_data = self:_create_server_data(v)
        if server_data then
            new_server_datas[server_data.key] = server_data
        end
    end
    self._servers_infos.server_datas = new_server_datas

    local this_server_data = new_server_datas[self._db_path_zone_server_data]
    if not this_server_data or this_server_data.create_index ~= self._keey_in_cluster_infos.create_index then
        self:_set_join_cluster(false)
    end

    local change_servers = {}

    for new_k, new_v in pairs(new_server_datas) do
        if not old_server_datas[new_k] then
            change_servers[new_k] = {old=nil, new=new_v}
        else
            local old_v = old_server_datas[new_k]
            if old_v.value ~= new_v.value then
                change_servers[new_k] = { old=old_v, new=new_v }
            end
        end
    end

    for old_k, old_v in pairs(old_server_datas) do
        if not new_server_datas[old_k] then
            change_servers[old_k] = { old=old_v, new=nil }
        end
    end

    for _, v in pairs(change_servers) do
        self:_fire_server_data_change(v)
    end
    -- 派发事件
    -- log_print("DiscoveryService:_process_servers_watch_ret", self._servers_infos, add_servers, delete_servers, change_servers)
end

function DiscoveryService:_process_servers_watch_ret(etcd_ret)
    -- log_print("DiscoveryService:_process_servers_watch_ret ", etcd_ret)
    if not etcd_ret:is_ok() then
        return
    end
    if self._keey_in_cluster_infos.create_index and etcd_ret.op_result.node.createdIndex < self._keey_in_cluster_infos.create_index then
        return
    end
    local action = etcd_ret.op_result.action
    local key = etcd_ret.op_result.node.key
    local change_ret = nil
    if Etcd_Const.Expire == action or Etcd_Const.Delete == action or Etcd_Const.CompareAndDelete == action
    then
        local old_v = self._servers_infos.server_datas[key]
        if old_v.modified_index < etcd_ret.op_result.node.modifiedIndex then -- watch到的数据必须比缓存的数据更新
            change_ret = { old=old_v, new=nil }
            self._servers_infos.server_datas[key] = nil
        end
    end
    if Etcd_Const.Create == action or Etcd_Const.Set == action then
        local server_data = self:_create_server_data(etcd_ret.op_result.node)
        if server_data then
            local old_data = self._servers_infos.server_datas[key]
            if not old_data or old_data.create_index < server_data.create_index then -- watch到的数据必须比缓存到的数据更新
                self._servers_infos.server_datas[key] = server_data
                if not old_data or old_data.value ~= server_data.value then -- watch到的数据必须有变更才fire
                    change_ret = { old=old_data, new=server_data }
                end
            end
        end
    end
    if change_ret then
        -- 派发事件
        -- log_print("DiscoveryService:_process_servers_watch_ret", change_ret, self._servers_infos)
        self:_fire_server_data_change(change_ret)
    end
end

function DiscoveryService:_fire_server_data_change(change_ret)
    if not change_ret then
        return
    end
    if not change_ret.old and not change_ret.new then
        return
    end
    local action = nil
    if change_ret.old and change_ret.new then
        action = Discovery_Service_Const.cluster_server_change
    end
    if change_ret.old and not change_ret.new then
        action = Discovery_Service_Const.cluster_server_leave
    end
    if not change_ret.old and change_ret.new then
        action = Discovery_Service_Const.cluster_server_join
    end
    self.server:fire(Discovery_Service_Event.cluster_server_change, action, change_ret.old, change_ret.new)
end

function DiscoveryService:_keep_in_cluster()
    if self._keey_in_cluster_infos.is_keeping or not self._cluster_server_id then
        return
    end
    if not self._is_allow_join_cluster or not self._zone_setting:is_ready() then
        return
    end
    local now_sec = logic_sec()
    if not self._is_joined_cluster then
        if now_sec - self._keey_in_cluster_infos.set_value_last_sec >= Discovery_Service_Const.refresh_ttl_sec / 4.0 then
            self._keey_in_cluster_infos.set_value_last_sec = now_sec
            self._keey_in_cluster_infos.is_keeping = true
            self._etcd_client:cmp_swap(self._db_path_zone_server_data, nil, nil, self._zone_server_data_json_str, Discovery_Service_Const.refresh_ttl_sec, function(op_id, op, ret)
                self._keey_in_cluster_infos.is_keeping = false
                if ret:is_ok() then
                    self:_set_join_cluster(true)
                    self._keey_in_cluster_infos.create_index = ret.op_result.node.createdIndex
                    self._keey_in_cluster_infos.modified_index = ret.op_result.node.modifiedIndex
                    self._keey_in_cluster_infos.refresh_ttl_last_sec = 0
                    self._servers_infos.wait_idx = nil -- 使得执行一次全量pull
                    -- log_print("DiscoveryService:_keep_in_cluster set", ret)
                else
                    self:_set_join_cluster(false)
                end
            end)
        end
    end
    if self._is_joined_cluster then
        if now_sec - self._keey_in_cluster_infos.refresh_ttl_last_sec >= Discovery_Service_Const.refresh_ttl_sec / 2.0 then
            self._keey_in_cluster_infos.refresh_ttl_last_sec = now_sec
            self._keey_in_cluster_infos.is_keeping = true
            self._etcd_client:refresh_ttl(self._db_path_zone_server_data, Discovery_Service_Const.refresh_ttl_sec, false, function(op_id, op, ret)
                self._keey_in_cluster_infos.is_keeping = false
                -- log_print("DiscoveryService:_keep_in_cluster refresh ttl", ret)
                if ret:is_ok() then
                    self._keey_in_cluster_infos.modified_index = ret.op_result.node.modifiedIndex
                    if ret.op_result.node.createdIndex ~= self._keey_in_cluster_infos.create_index then
                        self:_set_join_cluster(false)
                    end
                else
                    self:_set_join_cluster(false)
                end
            end)
        end
    end
end

function DiscoveryService:_on_event_zone_setting_allow_join_servers_diff(key, diff_type, value)
    local old_value = self._is_allow_join_cluster
    self._is_allow_join_cluster = self._zone_setting:is_server_allow_join(self._cluster_server_name)
    if old_value and old_value ~= self._is_allow_join_cluster then
        if self._is_joined_cluster and self._keey_in_cluster_infos.modified_index then
            self._etcd_client:cmp_delete(self._db_path_zone_server_data, self._keey_in_cluster_infos.modified_index, self._zone_server_data_json_str, false,
                    function (op_id, op, ret)
                        if ret:is_ok() then
                            self:_set_join_cluster(false)
                        end
                    end)
        end
    end
end

function DiscoveryService:_set_join_cluster(is_joined)
    local is_change = self._is_joined_cluster ~= is_joined
    self._is_joined_cluster = is_joined
    if not self._is_joined_cluster then
        self._keey_in_cluster_infos.create_index = nil
    end
    if is_change then
        self.server:fire(Discovery_Service_Event.cluster_join_state_change, self._is_joined_cluster)
    end
end

function DiscoveryService:is_joined_cluster()
    return self._is_joined_cluster
end

---@return table<string, ZoneServerJsonData>
function DiscoveryService:get_server_datas()
    return self._servers_infos.server_datas
end

function DiscoveryService:get_cluster_server_id()
    return self._cluster_server_id
end

function DiscoveryService:get_self_server_key()
    return self._db_path_zone_server_data
end

---@return ZoneServerJsonData
function DiscoveryService:get_self_server_data()
    return self._zone_server_data
end

function DiscoveryService:get_self_server_data_str()
    return self._zone_server_data_json_str
end

function DiscoveryService:get_self_cluster_server_name()
    return self._cluster_server_name
end


