
---@class GameServiceMgr: GameServiceMgrBase
GameServiceMgr = class("GameServiceMgr", ServiceMgrBase)

function GameServiceMgr:ctor(server)
    GameServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_game_service)
end

function GameServiceMgr:_on_init()
    do
        local svc = ServerRoleShadow:new(self, Service_Name.work_world_shadow, self.server:get_zone_name(), Server_Role.World)
        svc:init()
        self:add_service(svc)
    end    
    do
        local svc = GameLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
