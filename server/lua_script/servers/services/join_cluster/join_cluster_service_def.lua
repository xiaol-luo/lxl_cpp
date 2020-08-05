
Join_Cluster_Service_Const = {}

Join_Cluster_Service_Const.refresh_ttl_sec = 5
Join_Cluster_Service_Const.db_path_format_apply_cluster_id = "/%s/unique_id" -- /$zone/unique_id
Join_Cluster_Service_Const.db_path_format_zone_server_data = "/%s/servers/%s.%s" -- /$zone/servers/$server_role.$server_name
Join_Cluster_Service_Const.db_path_format_zone_server_dir = "/%s/servers" -- /$zone/servers
Join_Cluster_Service_Const.cluster_server_join = "cluster_server_join"
Join_Cluster_Service_Const.cluster_server_leave = "cluster_server_leave"
Join_Cluster_Service_Const.cluster_server_change = "cluster_server_change"

Join_Cluster_Service_Const.cluster_server_name_format = "%s.%s" -- $server_role.$server_name


---@class Join_Cluster_Service_Event
Join_Cluster_Service_Event = {}
Join_Cluster_Service_Event.cluster_join_state_change = "Join_Cluster_Service_Event.cluster_join_state_change"
