local Server_Root_Path = "servers.server_impl.fight"

local service_files = {
    dir = Server_Root_Path,
    files = {
        "fight_service_mgr",
        "fight_logic_service",
    }
}

local logic_entities_files = {
    dir = path_combine(Server_Root_Path, "logic_entities"),
    files = {
        "logic_entity_def",
        "fight_mgr.fight_mgr",
    }
}

local files = {
    service_files,
    logic_entities_files,
}

return files