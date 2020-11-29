
return
{
	{
        -- dir = ".",
        files =
        {
			"service_main",
			"service_main__client_cnn_mgr",
			"service_main__msg_handler",
			"service_main__rpc_mgr",
			"service_main__setup_logics",
			"service_require_files",

        },
        includes =
        {
			"client_cnn.include",
			"client_mgr.include",
			"net.include",
        },
    },
}