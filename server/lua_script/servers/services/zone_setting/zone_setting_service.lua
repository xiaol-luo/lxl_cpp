
---@class ZoneSettingService: ServiceBase
ZoneSettingService = ZoneSettingService or class("ZoneSettingService", ServiceBase)

function ZoneSettingService:ctor(service_mgr, service_name)
    ZoneSettingService.super.ctor(self, service_mgr, service_name)
    self._watch_path = nil
    self._zone_setting_watcher = nil
    self._event_binder = EventBinder:new()
    self._etcd_client = nil

    self._is_setting_ready = false
    ---@type table<string, number>
    self._zone_role_min_nums = nil
    ---@type table<string, boolean>
    self._zone_allow_join_servers = nil -- key=name

    self._db_path_zone_setting = nil
    self._db_path_zone_allow_join_servers = nil
    self._db_path_zone_role_min_nums = nil
    self._db_path_is_setting_ready = nil
end

function ZoneSettingService:_on_init()
    ZoneSettingService.super:_on_init(self)
    local etcd_setting = self.server.etcd_service_discovery_setting
    self._watch_path = string.format(Zone_Setting_Const.db_path_zone_setting_format, self.server.zone)
    self._zone_setting_watcher = EtcdWatcher:new(etcd_setting.host, etcd_setting.user, etcd_setting.pwd, self._watch_path)
    self._event_binder:bind(self._zone_setting_watcher, Etcd_Watch_Event.watch_result_change, Functional.make_closure(self._on_zone_setting_change, self))
    self._event_binder:bind(self._zone_setting_watcher, Etcd_Watch_Event.watch_result_diff, Functional.make_closure(self._on_zone_setting_diff, self))

    self._etcd_client = EtcdClient:new(etcd_setting.host, etcd_setting.user, etcd_setting.pwd)
    self._db_path_zone_setting = string.format(Zone_Setting_Const.db_path_zone_setting_format, self.server.zone)
    self._db_path_zone_allow_join_servers = string.format(Zone_Setting_Const.db_path_zone_allow_join_servers_format, self.server.zone)
    self._db_path_zone_role_min_nums = string.format(Zone_Setting_Const.db_path_zone_role_min_nums_format, self.server.zone)
    self._db_path_is_setting_ready = string.format(Zone_Setting_Const.db_path_is_setting_ready_format, self.server.zone)
end

function ZoneSettingService:_on_start()
    ZoneSettingService.super._on_start(self)
    self._zone_setting_watcher:start()
end

function ZoneSettingService:_on_stop()
    ZoneSettingService.super._on_stop(self)
    self._zone_setting_watcher:stop()
end

function ZoneSettingService:_on_release()
    ZoneSettingService.super._on_release(self)
end

function ZoneSettingService:_on_update()
    ZoneSettingService.super._on_update(self)

    local now_sec = logic_sec()
--[[    -- for test
    if not self._zone_server_setting_is_setted or now_sec - self._zone_server_setting_is_setted > 10 then
        self._zone_server_setting_is_setted = now_sec

        local min_role_num = {
            { role="world", num=1 },
        }
        local allow_join_servers = {
            "world.luo",
        }

        for _, v in ipairs(min_role_num) do
            local key = string.format("%s/%s", self._db_path_zone_role_min_nums, v.role)
            self._etcd_client:set(key, v.num)
        end
        for _, v in ipairs(allow_join_servers) do
            local key = string.format("%s/%s", self._db_path_zone_allow_join_servers, v)
            self._etcd_client:set(key, 1)
        end
    end

    -- for test
    if not self._last_set_sec or now_sec - self._last_set_sec > 10 then
        self._last_set_sec = now_sec
        if math.random() > 0.5 then
            self._etcd_client:set(string.format("%s/file_%s", self._watch_path, math.random(1, 2)),
                    math.random(), math.random(10, 20))
        else
            self._etcd_client:set(string.format("%s/dir_%s/file_%s", self._watch_path, math.random(1, 2),
                    math.random(1, 1)), math.random(), math.random(10, 20))
        end
    end]]
end

---@param watch_result EtcdWatchResult
---@param etcd_watcher EtcdWatcher
function ZoneSettingService:_on_zone_setting_change(watch_result, etcd_watcher)
    local old_zone_allow_join_servers = self._zone_allow_join_servers or {}
    self._zone_allow_join_servers = {}
    for key, node in pairs(watch_result:get_dir_nodes(self._db_path_zone_allow_join_servers)) do
        local value = (tonumber(node.value) ~= 0)
        self._zone_allow_join_servers[key] = value

        local old_value = old_zone_allow_join_servers[key] and old_zone_allow_join_servers[key] or false
        if old_value ~= value then
            self:fire(Zone_Setting_Event.zone_setting_allow_join_servers_diff, key, Zone_Setting_Diff.upsert, value)
        end
        old_zone_allow_join_servers[key] = nil
    end
    for key, value in pairs(old_zone_allow_join_servers) do
        self:fire(Zone_Setting_Event.zone_setting_allow_join_servers_diff, key, Zone_Setting_Diff.delete, false)
    end

    local old_zone_role_min_nums = self._zone_role_min_nums or {}
    self._zone_role_min_nums = {}
    for key, node in pairs(watch_result:get_dir_nodes(self._db_path_zone_role_min_nums)) do
        local value = tonumber(node.value)
        self._zone_role_min_nums[key] = value

        local old_value = old_zone_role_min_nums[key] and old_zone_role_min_nums[key] or 0
        if old_value ~= value then
            self:fire(Zone_Setting_Event.zone_setting_role_min_nums_diff, key, Zone_Setting_Diff.upsert, value)
        end
        old_zone_role_min_nums[key] = nil
    end
    for key, value in pairs(old_zone_role_min_nums) do
        self:fire(Zone_Setting_Event.zone_setting_role_min_nums_diff, key, Zone_Setting_Diff.delete, false)
    end

    if true or not self._is_setting_ready then
        local node = watch_result:get_node(self._db_path_is_setting_ready)
        if node and #node.value > 0 then
            local is_ready =  tonumber(node.value) > 0
            if is_ready then
                self._is_setting_ready = true
                self:fire(Zone_Setting_Event.zone_setting_is_ready)
            end
        end
    end

    log_print("ZoneSettingService:_on_zone_setting_change", self._zone_allow_join_servers or {}, self._zone_role_min_nums or {})
end

---@param key string
---@param result_diff_type Etcd_Watch_Result_Diff
---@param new_node EtcdResultNode
function ZoneSettingService:_on_zone_setting_diff(key, result_diff_type, new_node)
    local dir_key = nil

    if self._zone_allow_join_servers then
        dir_key = self._db_path_zone_allow_join_servers .. "/"
        if 1 == string.find(key, dir_key) then
            if Etcd_Watch_Result_Diff.Delete == result_diff_type then
                local new_value = false
                local old_value = self._zone_allow_join_servers[key] and self._zone_allow_join_servers[key] or false
                self._zone_allow_join_servers[key] = nil
                if old_value ~= new_value then
                    self:fire(Zone_Setting_Event.zone_setting_allow_join_servers_diff, key, Zone_Setting_Diff.delete, setting)
                end
            else
                local new_value = (tonumber(new_node.value) ~= 0)
                local old_value = self._zone_allow_join_servers[key] and self._zone_allow_join_servers[key] or false
                self._zone_allow_join_servers[key] = new_value
                if new_value ~= old_value then
                    self:fire(Zone_Setting_Event.zone_setting_allow_join_servers_diff, key, Zone_Setting_Diff.upsert, new_value)
                end
            end
        end
    end

    if self._zone_role_min_nums then
        dir_key = self._db_path_zone_role_min_nums .. "/"
        if 1 == string.find(key, dir_key) then
            if Etcd_Watch_Result_Diff.Delete == result_diff_type then
                local new_value = 0
                local old_value = self._zone_role_min_nums[key] and self._zone_role_min_nums[key] or 0
                self._zone_role_min_nums[key] = nil
                if old_value ~= new_value then
                    self:fire(Zone_Setting_Event.zone_setting_role_min_nums_diff, key, Zone_Setting_Diff.delete, 0)
                end
            else
                local new_value = tonumber(new_node.value)
                local old_value = self._zone_role_min_nums[key] and self._zone_role_min_nums[key] or 0
                self._zone_role_min_nums[key] = new_value
                if old_value ~= new_value then
                    self:fire(Zone_Setting_Event.zone_setting_role_min_nums_diff, key, Zone_Setting_Diff.upsert, new_value)
                end
            end
        end
    end

    if not self._is_setting_ready and Etcd_Watch_Result_Diff.Delete ~= result_diff_type and new_node.key == self._db_path_is_setting_ready then
        if new_node and #new_node.value > 0 then
            local is_ready =  tonumber(new_node.value) > 0
            if is_ready then
                self._is_setting_ready = true
                self:fire(Zone_Setting_Event.zone_setting_is_ready)
            end
        end
    end

    log_print("ZoneSettingService:_on_zone_setting_diff", self._is_setting_ready,  self._zone_allow_join_servers or {}, self._zone_role_min_nums or {})
end

function ZoneSettingService:is_ready()
    return self._is_setting_ready
end

function ZoneSettingService:get_role_min_num(role)
    local ret = nil
    if self._zone_role_min_nums then
        if is_string(role) and #role > 0 then
            local key = string.format("%s/%s", self._db_path_zone_role_min_nums, role)
            ret = self._zone_role_min_nums[key]
        end
    end
    return ret
end

function ZoneSettingService:is_server_allow_join(server_name)
    local ret = false
    if self._zone_allow_join_servers then
        if is_string(server_name) and #server_name > 0 then
            local key = string.format("%s/%s", self._db_path_zone_allow_join_servers, server_name)
            ret = self._zone_allow_join_servers[key] or false
        end
    end
    return ret
end


