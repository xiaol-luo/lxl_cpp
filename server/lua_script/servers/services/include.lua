
local files = {
    prefix = "servers.services",
    files = {
        "service_def",
        "service_base",
        "service_mgr_base",
        "custom_service_help_fn",
        "hotfix_service",

        "join_cluster.join_cluster_service_def",
        "join_cluster.join_cluster_service",
        "join_cluster.zone_server_json_data",

        "discovery.discovery_service_def",
        "discovery.discovery_service",
        "discovery.discovery_server_data",

        "peer_net.peer_net_def",
        "peer_net.peer_net_cnn_state",
        "peer_net.peer_net_server_state",
        "peer_net.peer_net_service",
        "peer_net.peer_net_service_cnn_logic",

        "rpc_service.rpc_service_def",
        "rpc_service.rpc_service_rpc_mgr",
        "rpc_service.rpc_service",
        "rpc_service.rpc_service_proxy",

        "zone_setting.zone_setting_def",
        "zone_setting.zone_setting_service",

        "logic_service.logic_service_def",
        "logic_service.logic_service_base",
        "logic_service.logic_entity_base",
        "logic_service.game_logic_entity",

        "client_net_service.client_net_def",
        "client_net_service.client_net_cnn",
        "client_net_service.client_net_service",

        "http_net_service.http_net_service",
        "http_net_service.http_net_service_proxy",
    }
}

return files