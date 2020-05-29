
function ServerBase:get_cluster_server_key()
    return self.discovery:get_self_server_key()
end

function ServerBase:get_cluster_server_value()
    return self.discovery:get_self_server_key()
end

function ServerBase:get_cluster_server_id()
    return self.discovery:get_cluster_server_id()
end

function ServerBase:is_joined_cluster()
    return self.discovery:is_joined_cluster()
end

function ServerBase:get_cluster_server_value_str()
    return self.discovery:get_self_server_data_str()
end


