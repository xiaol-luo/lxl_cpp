
---@class RoomLogicService:LogicServiceBase
---@field room_mgr RoomMgr
RoomLogicService = RoomLogicService or class("LogicService", LogicServiceBase)

function RoomLogicService:_on_init()
    RoomLogicService.super._on_init(self)

    do
        local logic = RoomMgr:new(self, Room_Logic_Name.room_mgr)
        logic:init()
        self:add_logic(logic)
    end

end