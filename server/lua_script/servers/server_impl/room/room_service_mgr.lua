
---@class RoomServiceMgr: ServiceMgrBase
---@field db_uuid DBUuidService
---@field logics RoomLogicService
RoomServiceMgr = class("RoomServiceMgr", ServiceMgrBase)

function RoomServiceMgr:ctor(server)
    RoomServiceMgr.super.ctor(self, server, CustomServiceHelpFn.setup_game_service)
end

function RoomServiceMgr:_on_init()
    do
        local svc = RoomLogicService:new(self, Service_Name.logics)
        svc:init()
        self:add_service(svc)
    end

    return true
end
