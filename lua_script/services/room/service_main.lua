
RoomService = RoomService or class("RoomService", GameServiceBase)

for _, v in ipairs(require("services.room.service_require_files")) do
    require(v)
end

function create_service_main()
    return RoomService:new()
end

function RoomService:ctor()
    RoomService.super.ctor(self)
end
