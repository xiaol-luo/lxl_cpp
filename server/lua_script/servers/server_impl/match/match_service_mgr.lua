
---@class MatchServiceMgr: ServiceMgrBase
---@field db_uuid DBUuidService
---@field logics CreateRoleLogicService
MatchServiceMgr = class("MatchServiceMgr", ServiceMgrBase)

function MatchServiceMgr:ctor(server)
    MatchServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_game_service)
end

function MatchServiceMgr:_on_init()
    do
        local svc = MatchLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
