
GameService = GameService or class("GameService", GameServiceBase)

for _, v in ipairs(require("services.game.service_require_files")) do
    require(v)
end

function create_service_main()
    return GameService:new()
end

function GameService:ctor()
    GameService.super.ctor(self)
    self.cb_client = nil
    self.redis_client = nil
end
