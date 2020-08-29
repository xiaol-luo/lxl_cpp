
---@class FightServiceMgr: ServiceMgrBase
---@field db_uuid DBUuidService
---@field logics FightLogicService
FightServiceMgr = class("FightServiceMgr", ServiceMgrBase)

function FightServiceMgr:ctor(server)
    FightServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_game_service)
end

function FightServiceMgr:_on_init()
    do
        local svc = FightLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
