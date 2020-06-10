

---@class ClusterStateService: ServiceBase
ClusterStateService = ClusterStateService or class("ClusterStateService", ServiceBase)

function ClusterStateService:ctor(service_mgr, service_name)
    ClusterStateService.super.ctor(self, service_mgr, service_name)
    self._is_zone_setting_ready = false
    self._role_min_nums = {}
    self._allow_join_servers = {}
    self._cluster_joined_servers = {}
    self._is_can_work = false
end

function ClusterStateService:_on_init()
    ClusterStateService.super:_on_init(self)
end

function ClusterStateService:_on_start()
    ClusterStateService.super._on_start(self)

    local zone_setting = self.server.zone_setting
    self._is_zone_setting_ready = zone_setting:is_ready()
    self._role_min_nums = zone_setting:get_role_min_nums()
    self._allow_join_servers = zone_setting:get_allow_join_servers()
    self._event_binder:bind(zone_setting, Zone_Setting_Event.zone_setting_allow_join_servers_diff, Functional.make_closure(self.on_event_allow_join_server_diff, self))
    self._event_binder:bind(zone_setting, Zone_Setting_Event.zone_setting_role_min_nums_diff, Functional.make_closure(self._on_event_role_min_nums_diff, self))
    self._event_binder:bind(zone_setting, Zone_Setting_Event.zone_setting_is_ready, Functional.make_closure(self._on_event_zone_setting_ready_change, self))

    local discovery_svc = self.server.discovery
    self._event_binder:bind(discovery_svc, Discovery_Service_Event.cluster_server_change, Functional.make_closure(self._on_event_cluster_server_change, self))
end

function ClusterStateService:_on_stop()
    ClusterStateService.super._on_stop(self)
    self._event_binder:release_all()
end

function ClusterStateService:_on_release()
    ClusterStateService.super._on_release(self)
end

function ClusterStateService:_on_update()
    ClusterStateService.super._on_update(self)
end

function ClusterStateService:on_event_allow_join_server_diff(key, diff_type, value)
    local old_value = self._allow_join_servers[key]
    local new_value = value or nil
    self._allow_join_servers[key] = value or nil
    if old_value ~= new_value then
        self:_check_cluster_can_work()
    end
end

function ClusterStateService:_on_event_role_min_nums_diff(key, diff_type, value)
    self._role_min_nums[key] = value
end

function ClusterStateService:_on_event_zone_setting_ready_change()
    local old_value = self._is_zone_setting_ready
    self._is_zone_setting_ready = true
    if old_value ~= self._is_zone_setting_ready then
        self:_check_cluster_can_work()
    end
end

function ClusterStateService:_on_event_cluster_server_change(action, old_server_data, new_server_data)
    local server_key = old_server_data and old_server_data.key or new_server_data.key
    local old_value = self._cluster_joined_servers[server_key]

    local new_value = nil
    if Discovery_Service_Const.cluster_server_join == action or Discovery_Service_Const.cluster_server_change == action then
        new_value = true
    end
    --if Discovery_Service_Const.cluster_server_leave == action then
    --    new_value = nil
    --end
    self._cluster_joined_servers[server_key] = new_value
    if old_value ~= new_value then
        self:_check_cluster_can_work()
    end
end

function ClusterStateService:_check_cluster_can_work()
    local is_can_work = true
    if not self._is_zone_setting_ready then
        is_can_work = false
    else
        local now_role_nums = {}
        for server_key, _ in pairs(self._cluster_joined_servers) do
            if self._allow_join_servers[server_key] then
                local role, name = extract_from_cluster_server_name(server_key)
                if role then
                    now_role_nums[role] = now_role_nums[role] or 0
                    now_role_nums[role] = now_role_nums[role] + 1
                end
            end
        end
        for role, num in pairs(self._role_min_nums) do
            local joined_num = now_role_nums[role] or 0
            if num > joined_num then
                is_can_work = false
                break
            end
        end
    end
    local old_value = self._is_can_work
    self._is_can_work = is_can_work
    if old_value ~= self._is_can_work then
        self:fire(Cluster_State_Event.cluster_can_work_change, self._is_can_work)
    end
end

function ClusterStateService:is_can_work()
    return self._is_can_work
end


