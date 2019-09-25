
function GameService:setup_modules()
    GameService.super.setup_modules(self)
    self:_init_db_client()
    self:_init_redis_client()
end
