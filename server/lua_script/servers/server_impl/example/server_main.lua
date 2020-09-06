

batch_require(require("servers.server_impl.example.server_require_files"))

ServiceMgr = ExampleServiceMgr

---@class ExampleServer : GameServerBase
ExampleServer = ExampleServer or class("ExampleServer", GameServerBase)

function create_server_main(init_setting, init_args)
    return ExampleServer:new(init_setting, init_args)
end

function ExampleServer:ctor(init_setting, init_args)
    ExampleServer.super.ctor(self, Server_Role.Fight, init_setting, init_args)
end

function ExampleServer:_on_init()
    local ret = ExampleServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function ExampleServer:_on_start()
    local ret = ExampleServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function ExampleServer:_on_stop()
    ExampleServer.super._on_stop(self)
end

function ExampleServer:_on_notify_quit_game()
    ExampleServer.super._on_notify_quit_game(self)
end

function ExampleServer:_check_can_quit_game()
    local can_quit = ExampleServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end