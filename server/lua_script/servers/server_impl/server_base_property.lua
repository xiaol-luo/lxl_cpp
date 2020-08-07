
function ServerBase:get_cluster_server_key()
    return self.join_cluster:get_server_key()
end

function ServerBase:get_cluster_server_id()
    return self.join_cluster:get_cluster_server_id()
end

function ServerBase:is_joined_cluster()
    return self.join_cluster:is_joined_cluster()
end

function ServerBase:get_cluster_server_data()
    return self.join_cluster:get_server_data()
end

function ServerBase:get_cluster_server_data_str()
    return self.join_cluster:get_server_data_json_str()
end

function ServerBase:get_cluster_server_name()
    return self.join_cluster:get_cluster_server_name()
end

function ServerBase:get_zone_name()
    return self.zone_name
end

function ServerBase:get_server_role()
    return self.server_role
end

function ServerBase:get_server_name()
    return self.server_name
end
