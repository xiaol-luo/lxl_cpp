
Join_Cluster_Service_Const = {}

Join_Cluster_Service_Const.refresh_ttl_sec = 5
Join_Cluster_Service_Const.db_path_format_apply_cluster_id = "/%s/unique_id" -- /$zone/unique_id
Join_Cluster_Service_Const.db_path_format_zone_server_data = "/%s/servers/%s.%s" -- /$zone/servers/$server_role.$server_name
Join_Cluster_Service_Const.db_path_format_zone_server_dir = "/%s/servers" -- /$zone/servers
Join_Cluster_Service_Const.cluster_server_join = "cluster_server_join"
Join_Cluster_Service_Const.cluster_server_leave = "cluster_server_leave"
Join_Cluster_Service_Const.cluster_server_change = "cluster_server_change"

Join_Cluster_Service_Const.cluster_server_name_format = "%s.%s" -- $server_role.$server_name

function gen_cluster_server_name(server_role, server_name)
    local ret = string.format(Join_Cluster_Service_Const.cluster_server_name_format, server_role, server_name)
    return ret
end

function extract_from_cluster_server_name(cluster_server_name)
    local server_role, server_name = nil, nil
    if cluster_server_name or #cluster_server_name > 0 then
        local tmps = string.split(cluster_server_name, "/")
        if #tmps > 0 then
            local strs = string.split(tmps[#tmps], ".")
            if 2 == #strs and #strs[1] > 0 and #strs[2] > 0 then
                server_role = string.lrtrim(strs[1], " ")
                server_name = string.lrtrim(strs[2], " ")
            end
        end
    end
    return server_role, server_name
end



---@class Join_Cluster_Service_Event
Join_Cluster_Service_Event = {}
Join_Cluster_Service_Event.cluster_join_state_change = "Join_Cluster_Service_Event.cluster_join_state_change"
