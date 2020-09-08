
local Server_Root_Path = "servers.server_impl.match"

local service_files = {
    dir = Server_Root_Path,
    files = {
        "match_service_mgr",
        "match_logic_service",
    }
}

local logic_entities_files = {
    dir = path_combine(Server_Root_Path, "logic_entities"),
    files = {
        "logic_entity_def",
        "match_mgr.match_mgr",
    }
}

local files = {
    service_files,
    logic_entities_files,
}

return files