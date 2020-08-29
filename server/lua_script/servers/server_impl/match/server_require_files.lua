local path_combine = function(...)
    ret = nil
    for _, v in ipairs({...}) do
        if nil == ret then
            ret = v
        else
            ret = string.format("%s.%s", ret, v)
        end
    end
    return ret
end

local Server_Root_Path = "servers.server_impl.match"

local service_files = {
    prefix = Server_Root_Path,
    files = {
        "match_service_mgr",
        "match_logic_service",
    }
}

local logic_entities_files = {
    prefix = path_combine(Server_Root_Path, "logic_entities"),
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