
Server_Role_Const = {}
Server_Role_Const.redis_key_world_work_adjusting_version_format = "%s-%s-adjusting-version" -- $zone_name-$server_role-adjusting-version
Server_Role_Const.redis_key_world_work_version_format = "%s-%s-version" -- $zone_name-$server_role-version
Server_Role_Const.redis_key_world_work_servers_format = "%s-%s-servers" -- $zone_name-$server_role-servers
Server_Role_Const.lead_rehash_duration_sec = 6
Server_Role_Const.guarantee_data_valid_duration_sec = 15
Server_Role_Const.parted_with_monitor_with_no_communication = 20
Server_Role_Const.parted_with_redis_with_no_communication = 20
Server_Role_Const.rpc_method_notify_server_data_format = "rpc_method_notify_server_datas_%s_%s" --rpc_method_notify_server_datas_$zone_name_$server_role
Server_Role_Const.rpc_method_query_server_data_format = "rpc_method_query_server_data_%s_%s" --rpc_method_notify_server_datas_$zone_name_$server_role
Server_Role_Const.event_adjusting_version_state_change_format = "event_adjusting_version_state_change_%s_%s" --event_adjusting_version_state_change_$zone_name_$server_role
Server_Role_Const.event_version_change_format = "event_version_change_%s_%s" --event_version_change_$zone_name_$server_role
Server_Role_Const.event_shadow_parted_state_change_format = "event_shadow_parted_state_change_%s_%s" --shadow_parted_state_change_$zone_name_$server_role


---@class ServerRoleMonitorSetting
---@field zone_name string
---@field role_name string
---@field redis_key_adjusting_version string
---@field redis_key_version string
---@field redis_key_servers string
---@field lead_rehash_duration_sec string
---@field guarantee_data_valid_duration_sec string
---@field parted_with_monitor_with_no_communication string
---@field parted_with_redis_with_no_communication string
---@field rpc_method_notify_server_data string
---@field rpc_method_query_server_data string
---@field rpc_method_query_server_data string
---@field event_adjusting_version_state_change string
---@field event_version_change string
---@field shadow_parted_state_change string
---@field observer_server_roles table
ServerRoleMonitorSetting = ServerRoleMonitorSetting or class("ServerRoleMonitor")

function ServerRoleMonitorSetting:ctor(zone_name, server_role_name, observer_server_roles)
    self.zone_name = zone_name
    self.role_name = server_role_name
    self.redis_key_adjusting_version = string.format(Server_Role_Const.redis_key_world_work_adjusting_version_format, self.zone_name, self.role_name)
    self.redis_key_version = string.format(Server_Role_Const.redis_key_world_work_version_format, self.zone_name, self.role_name)
    self.redis_key_servers = string.format(Server_Role_Const.redis_key_world_work_servers_format, self.zone_name, self.role_name)
    self.lead_rehash_duration_sec = Server_Role_Const.lead_rehash_duration_sec
    self.guarantee_data_valid_duration_sec = Server_Role_Const.guarantee_data_valid_duration_sec
    self.parted_with_monitor_with_no_communication = Server_Role_Const.parted_with_monitor_with_no_communication
    self.parted_with_redis_with_no_communication = Server_Role_Const.parted_with_redis_with_no_communication
    self.rpc_method_notify_server_data = string.format(Server_Role_Const.rpc_method_notify_server_data_format, self.zone_name, self.role_name)
    self.rpc_method_query_server_data = string.format(Server_Role_Const.rpc_method_query_server_data_format, self.zone_name, self.role_name)
    self.event_adjusting_version_state_change = string.format(Server_Role_Const.event_adjusting_version_state_change_format, self.zone_name, self.role_name)
    self.event_version_change = string.format(Server_Role_Const.event_version_change_format, self.zone_name, self.role_name)
    self.event_shadow_parted_state_change = string.format(Server_Role_Const.event_shadow_parted_state_change_format, self.zone_name, self.role_name)
    self.observer_server_roles = observer_server_roles or {}
end








