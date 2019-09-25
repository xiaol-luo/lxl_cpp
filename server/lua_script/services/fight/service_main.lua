
FightService = FightService or class("FightService", GameServiceBase)

for _, v in ipairs(require("services.fight.service_require_files")) do
    require(v)
end

function create_service_main()
    return FightService:new()
end

function FightService:ctor()
    FightService.super.ctor(self)
end
