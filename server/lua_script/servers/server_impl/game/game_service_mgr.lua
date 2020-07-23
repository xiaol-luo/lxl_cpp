
---@class GameServiceMgr: GameServiceMgrBase
GameServiceMgr = class("GameServiceMgr", ServiceMgrBase)

function GameServiceMgr:ctor(server)
    GameServiceMgr.super.ctor(self, server)
end

function GameServiceMgr:_on_init()
    local world_online_shadown = OnlineWorldShadow:new(self, Service_Name.online_world_shadow)
    world_online_shadown:init()
    self:add_service(world_online_shadown)

    do
        local svc = GameLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
