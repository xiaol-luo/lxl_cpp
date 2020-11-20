local files = {
    "servers.server_impl.game.game_service_mgr",
    "servers.server_impl.game.game_logic_service",

    "servers.services.server_role_monitor.server_role_monitor_def",
    "servers.services.server_role_monitor.server_role_monitor",
    "servers.services.server_role_monitor.server_role_shadow",

    "servers.server_impl.game.logic_entities.logic_entity_def",

    "servers.server_impl.game.logic_entities.game_role_mgr.game_role_def",
    "servers.server_impl.game.logic_entities.game_role_mgr.game_role",
    "servers.server_impl.game.logic_entities.game_role_mgr.game_role_mgr",
    "servers.server_impl.game.logic_entities.game_role_mgr.game_role_mgr_handle_client_msg_fns",

    "servers.server_impl.game.logic_entities.forward_msg.game_forward_msg",

    {
      dir = "servers.server_impl.game.logic_entities",
      includes = {
          -- "game_role_mgr.game_role_module.include",
          "include",
      }
    },
    -- require("servers.server_impl.game.logic_entities.game_role_mgr.game_role_module.include")
}

return files