
MatchService = MatchService or class("MatchService", GameServiceBase)

for _, v in ipairs(require("services.match.service_require_files")) do
    require(v)
end

function create_service_main()
    return MatchService:new()
end

function MatchService:ctor()
    MatchService.super.ctor(self)
end
