
GameService = GameService or class("GameService", GameServiceBase)

for _, v in ipairs(require("services.game.service_require_files")) do
    require(v)
end

function create_service_main()
    return GameService:new()
end

function GameService:ctor()
    GameService.super.ctor(self)
    self.db_client = nil
    self.query_db = nil
end

function GameService:setup_modules()
    GameService.super.setup_modules(self)
    self:_init_db_client()
end
