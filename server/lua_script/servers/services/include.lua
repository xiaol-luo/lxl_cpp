
return
{
	{
        -- dir = ".",
        files =
        {
			"service_def",
			"service_mgr_base",
			"service_base",
			"custom_service_help_fn",
			"hotfix_service",

        },
        includes =
        {
			"client_net_service.include",
			"db_uuid.include",
			"discovery.include",
			"http_net_service.include",
			"join_cluster.include",
			"logic_service.include",
			"peer_net.include",
			"rpc_service.include",
			"server_role_monitor.include",
			"service_module.include",
			"zone_setting.include",
        },
    },
}