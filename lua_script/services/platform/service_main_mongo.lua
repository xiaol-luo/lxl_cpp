
function PlatformService:_init_db_client()
    self.db_client = MongoClientModule:new(self.module_mgr, "db_client")
    self.module_mgr:add_module(self.db_client)
    local mongo_setting = SERVICE_SETTING["mongo"]
    self.query_db = mongo_setting["db"]
    self.db_client:init(mongo_setting["host"], mongo_setting["auth_db"], mongo_setting["user"], mongo_setting["pwd"])
end