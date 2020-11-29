
return
{
	{
        -- dir = ".",
        files =
        {
			"service_main",
			"service_main__mongo",
			"service_main__msg_handler",
			"service_main__redis",
			"service_main__rpc_mgr",
			"service_main__setup_logics",
			"service_main__setup_modules",
			"service_require_files",

        },
        includes =
        {
			"common.include",
			"service_logics.include",
        },
    },
}