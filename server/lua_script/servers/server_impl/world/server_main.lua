
WorldServer = WorldServer or class("WorldServer")

for _, v in ipairs(require("servers.server_impl.world.server_require_files")) do
    require(v)
end

function create_server_main()
    return WorldServer:new()
end

function WorldServer:ctor()

end

function WorldServer:init()
    log_debug("WorldServer:init")
end

function WorldServer:start()
    log_debug("WorldServer:start")
end

function WorldServer:stop()
    log_debug("WorldServer:stop")
end

function WorldServer:OnNotifyQuitGame()
    log_debug("WorldServer:OnNotifyQuitGame")
end

function WorldServer:CheckCanQuitGame()
    return true
end
