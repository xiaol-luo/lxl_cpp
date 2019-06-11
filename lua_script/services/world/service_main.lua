
WorldService = WorldService or class("WorldService", GameServiceBase)

for _, v in ipairs(require("services.world.service_require_files")) do
    require(v)
end

function create_service_main()
    return WorldService:new()
end

function WorldService:ctor()
    WorldService.super.ctor(self)
    self.db_client = nil
    self.query_db = nil
    self.db_uuid = nil
end

function WorldService:setup_modules()
    self:_init_db_uuid()
    self:_init_db_client()
    WorldService.super.setup_modules(self)
end

