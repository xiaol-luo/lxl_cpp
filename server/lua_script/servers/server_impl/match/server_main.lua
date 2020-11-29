

batch_require(require("servers.server_impl.match.server_require_files"))
include_file("servers.server_impl.match.include")

ServiceMgr = MatchServiceMgr

---@class MatchServer : GameServerBase
MatchServer = MatchServer or class("MatchServer", GameServerBase)

function create_server_main(init_setting, init_args)
    return MatchServer:new(init_setting, init_args)
end

function MatchServer:ctor(init_setting, init_args)
    MatchServer.super.ctor(self, Server_Role.Match, init_setting, init_args)
end

function MatchServer:_on_init()
    local ret = MatchServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function MatchServer:_on_start()
    local ret = MatchServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function MatchServer:_on_stop()
    MatchServer.super._on_stop(self)
end

function MatchServer:_on_notify_quit_game()
    MatchServer.super._on_notify_quit_game(self)
end

function MatchServer:_check_can_quit_game()
    local can_quit = MatchServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end