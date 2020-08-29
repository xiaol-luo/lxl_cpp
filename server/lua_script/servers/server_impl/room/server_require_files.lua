local Server_Root_Path = "servers.server_impl.room"

local service_files = {
    prefix = Server_Root_Path,
    files = {
        "room_service_mgr",
        "room_logic_service",
    }
}

local logic_entities_files = {
    prefix = path_combine(Server_Root_Path, "logic_entities"),
    files = {
        "logic_entity_def",
        "room_mgr.room_mgr",
    }
}

local files = {
    service_files,
    logic_entities_files,
}

return files