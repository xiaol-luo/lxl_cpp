
---@class DiscoveryService: ServiceBase
DiscoveryService = DiscoveryService or class("DiscoveryService", ServiceBase)

function DiscoveryService:ctor(service_mgr, service_name)
    DiscoveryService.super.ctor(self, service_mgr, service_name)
    ---@type EtcdClient
    self._etcd_client = nil
    self._db_path_watch_server_dir = nil
    ---@type ZoneSettingService
    self._zone_setting = nil

    self._servers_infos = {
        is_watching = false,
        wait_idx = nil,
        ---@type table<string, ZoneServerJsonData>
        server_datas = {},
    }
    self._is_cluster_can_work = false

end

function DiscoveryService:_on_init()
    DiscoveryService.super._on_init(self)
    self._db_path_watch_server_dir = string.format(Discovery_Service_Const.db_path_format_zone_server_dir, self.server.zone_name)
    local etcd_setting = self.server.etcd_service_discovery_setting
    self._etcd_client = EtcdClient:new(etcd_setting.host, etcd_setting.user, etcd_setting.pwd)
    self._zone_setting = self.server.zone_setting
end

function DiscoveryService:_on_start()
    DiscoveryService.super._on_start(self)
    self._etcd_client:set(self._db_path_watch_server_dir, nil, nil, true)
    self._event_binder:bind(self._zone_setting, Zone_Setting_Event.zone_setting_allow_join_servers_diff,
            Functional.make_closure(self.on_event_allow_join_server_diff, self))
    self._event_binder:bind(self._zone_setting, Zone_Setting_Event.zone_setting_role_min_nums_diff,
            Functional.make_closure(self._on_event_role_min_nums_diff, self))
end

function DiscoveryService:_on_stop()
    DiscoveryService.super._on_stop(self)
end

function DiscoveryService:_on_update()
    DiscoveryService.super._on_update(self)
    self:_watch_servers_data()
end


function DiscoveryService:_watch_servers_data()
    -- 监视集群内server变化
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
    local action = etcd_ret.op_result.action
    local key = etcd_ret.op_result.node.key
    local change_ret = nil
    if Etcd_Const.Expire == action or Etcd_Const.Delete == action or Etcd_Const.CompareAndDelete == action then
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
    self:_check_cluster_can_work()
end

---@return table<string, ZoneServerJsonData>
function DiscoveryService:get_server_datas()
    return self._servers_infos.server_datas
end


function DiscoveryService:on_event_allow_join_server_diff(key, diff_type, value)
    self:_check_cluster_can_work()
end

function DiscoveryService:_on_event_role_min_nums_diff(key, diff_type, value)
    self:_check_cluster_can_work()
end


function DiscoveryService:_check_cluster_can_work()
    self._zone_setting:get_allow_join_servers()
    local now_role_nums = {}
    for server_key, _ in pairs(self._servers_infos.server_datas) do
        local cluster_server_name, role, _ = extract_cluster_server_name(server_key)
        if self._zone_setting:is_server_allow_join(cluster_server_name) then
            if role then
                now_role_nums[role] = now_role_nums[role] or 0
                now_role_nums[role] = now_role_nums[role] + 1
            end
        end
    end

    local is_can_work = true
    for db_path, num in pairs(self._zone_setting:get_role_min_nums()) do
        local str_array = string.split(db_path, "/")
        if #str_array > 0 then
            local role = string.lrtrim(str_array[#str_array], " ")
            local joined_num = now_role_nums[role] or 0
            if num > joined_num then
                is_can_work = false
                break
            end
        else
            log_warn("DiscoveryService:_check_cluster_can_work zone_setting:get_role_min_nums(), db_path is invalid: %s", db_path)
            -- _is_cluster_can_work = false
        end
    end

    local old_value = self._is_cluster_can_work
    self._is_cluster_can_work = is_can_work
    if old_value ~= self._is_cluster_can_work then
        self:fire(Discovery_Service_Event.cluster_can_work_change, self._is_cluster_can_work)
    end
end

function DiscoveryService:is_cluster_can_work()
    return self._is_cluster_can_work
end

