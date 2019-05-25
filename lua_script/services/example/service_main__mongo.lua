
function ExampleService:_init_db_client()
    self.db_client = MongoClientModule:new(self.module_mgr, "db_client")
    self.module_mgr:add_module(self.db_client)

    -- log_debug("_init_db_client %s", self.service_cfg)
    local mongo_cfg = self.all_service_cfg:get_third_party_service(Service_Const.Mongo_Service, self.service_cfg[Service_Const.Mongo_Service])
    assert(mongo_cfg)
    self.query_db = self.service_cfg[Service_Const.Db_name]
    self.db_client:init(
            mongo_cfg[Service_Const.Host],
            mongo_cfg[Service_Const.Auth_Db],
            mongo_cfg[Service_Const.User],
            mongo_cfg[Service_Const.Pwd])
end