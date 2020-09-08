local Server_Root_Path = "servers.server_impl.example"

local service_files = {
    dir = Server_Root_Path,
    files = {
        "example_service_mgr",
        "example_logic_service",
    }
}

local logic_entities_files = {
    dir = path_combine(Server_Root_Path, "logic_entities"),
    files = {
        "logic_entity_def",
        "example_mgr.example_mgr",
    }
}

local files = {
    service_files,
    logic_entities_files,
}

return files