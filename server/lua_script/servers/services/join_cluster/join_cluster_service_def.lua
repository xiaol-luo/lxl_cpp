
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

function extract_cluster_server_name(server_key_or_cluster_server_name)
    local cluster_server_name, server_role, server_name = nil, nil, nil
    if server_key_or_cluster_server_name or #server_key_or_cluster_server_name > 0 then
        local tmps = string.split(server_key_or_cluster_server_name, "/")
        if #tmps > 0 then
            local strs = string.split(tmps[#tmps], ".")
            if 2 == #strs and #strs[1] > 0 and #strs[2] > 0 then
                server_role = string.lrtrim(strs[1], " ")
                server_name = string.lrtrim(strs[2], " ")
            end
        end
    end
    if server_role and #server_role > 0 and server_name and #server_name > 0 then
        cluster_server_name = gen_cluster_server_name(server_role, server_name)
    end
    return cluster_server_name, server_role, server_name
end

function gen_cluster_server_key(zone_name, server_role, server_name)
    return string.format(Join_Cluster_Service_Const.db_path_format_zone_server_data, zone_name, server_role, server_name)
end

---@class Join_Cluster_Service_Event
Join_Cluster_Service_Event = {}
Join_Cluster_Service_Event.cluster_join_state_change = "Join_Cluster_Service_Event.cluster_join_state_change"
