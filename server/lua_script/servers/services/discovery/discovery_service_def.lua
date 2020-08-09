
Discovery_Service_Const = {}

Discovery_Service_Const.refresh_ttl_sec = 5
Discovery_Service_Const.db_path_format_apply_cluster_id = "/%s/unique_id" -- /$zone/unique_id
Discovery_Service_Const.db_path_format_zone_server_data = "/%s/servers/%s.%s" -- /$zone/servers/$server_role.$server_name
Discovery_Service_Const.db_path_format_zone_server_dir = "/%s/servers" -- /$zone/servers
Discovery_Service_Const.cluster_server_join = "cluster_server_join"
Discovery_Service_Const.cluster_server_leave = "cluster_server_leave"
Discovery_Service_Const.cluster_server_change = "cluster_server_change"

---@class Discovery_Service_Event
Discovery_Service_Event = {}
Discovery_Service_Event.cluster_server_change = "Discovery_Service_Event.cluster_server_change"
Discovery_Service_Event.cluster_can_work_change = "Discovery_Service_Event.cluster_can_work_change"

function gen_cluster_server_key(zone_name, server_role, server_name)
    return string.format(Discovery_Service_Const.db_path_format_zone_server_data, zone_name, server_role, server_name)
end