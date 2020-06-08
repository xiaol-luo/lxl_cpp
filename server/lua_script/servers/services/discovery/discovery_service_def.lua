
Discovery_Service_Const = {}

Discovery_Service_Const.refresh_ttl_sec = 5
Discovery_Service_Const.db_path_format_apply_cluster_id = "/%s/unique_id" -- /$zone/unique_id
Discovery_Service_Const.db_path_format_zone_server_data = "/%s/servers/%s.%s" -- /$zone/servers/$server_role.$server_name
Discovery_Service_Const.db_path_format_zone_server_dir = "/%s/servers" -- /$zone/servers
Discovery_Service_Const.cluster_server_join = "cluster_server_join"
Discovery_Service_Const.cluster_server_leave = "cluster_server_leave"
Discovery_Service_Const.cluster_server_change = "cluster_server_change"

Discovery_Service_Const.cluster_server_name_format = "%s.%s" -- $server_role.$server_name

function gen_cluster_server_name(server_role, server_name)
    local ret = string.format(Discovery_Service_Const.cluster_server_name_format, server_role, server_name)
    return ret
end

function extract_from_cluster_server_name(cluster_server_name)
    local server_role, server_name = nil, nil
    local strs = string.split(cluster_server_name, ".")
    if #strs < 2 and #strs[1] > 0 and #strs[2] > 0 then
        server_role = string.lrtrim(strs[1], " ")
        server_name = string.lrtrim(strs[2], " ")
    end
    return server_role, server_name
end


---@class Discovery_Service_Event
Discovery_Service_Event = {}
Discovery_Service_Event.cluster_join_state_change = "Discovery_Service_Event.cluster_join_state_change"
Discovery_Service_Event.cluster_server_change = "Discovery_Service_Event.cluster_server_change"