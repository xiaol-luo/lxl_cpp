

include_file("servers.server_impl.room.include")

ServiceMgr = RoomServiceMgr

---@class RoomServer : GameServerBase
RoomServer = RoomServer or class("RoomServer", GameServerBase)

function create_server_main(init_setting, init_args)
    return RoomServer:new(init_setting, init_args)
end

function RoomServer:ctor(init_setting, init_args)
    RoomServer.super.ctor(self, Server_Role.Room, init_setting, init_args)
end

function RoomServer:_on_init()
    local ret = RoomServer.super._on_init(self)
    if not ret then
        return false
    end
    return true
end

function RoomServer:_on_start()
    local ret = RoomServer.super._on_start(self)
    if not ret then
        return false
    end
    return true
end

function RoomServer:_on_stop()
    RoomServer.super._on_stop(self)
end

function RoomServer:_on_notify_quit_game()
    RoomServer.super._on_notify_quit_game(self)
end

function RoomServer:_check_can_quit_game()
    local can_quit = RoomServer.super._check_can_quit_game(self)
    if not can_quit then
        return false
    end
    return true
end