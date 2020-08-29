

batch_require(require("servers.server_impl.fight.server_require_files"))

ServiceMgr = FightServiceMgr

---@class FightServer : GameServerBase
FightServer = FightServer or class("FightServer", GameServerBase)

function create_server_main(init_setting, init_args)
    return FightServer:new(init_setting, init_args)
end

function FightServer:ctor(init_setting, init_args)
    FightServer.super.ctor(self, Server_Role.Fight, init_setting, init_args)
end

function FightServer:_on_init()
    local ret = FightServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function FightServer:_on_start()
    local ret = FightServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function FightServer:_on_stop()
    FightServer.super._on_stop(self)
end

function FightServer:_on_notify_quit_game()
    FightServer.super._on_notify_quit_game(self)
end

function FightServer:_check_can_quit_game()
    local can_quit = FightServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end