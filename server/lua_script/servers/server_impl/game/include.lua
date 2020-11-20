local files = {

    -- services
    {
        dir = "servers.services",
        includes =
        {
            "server_role_monitor.include",
        },
    },

    -- server logic
    {
        dir = "servers.server_impl.game",
        files =
        {
            "game_service_mgr",
            "game_logic_service",
        },
        includes =
        {
            "logic_entities.include",
        },
    },
}

return files