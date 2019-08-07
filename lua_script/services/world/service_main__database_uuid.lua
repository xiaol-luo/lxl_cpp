
function WorldService:_init_db_uuid()
    self.module_mgr:add_module(DatabaseUuidModule:new(self.module_mgr, "db_uuid"))

    -- log_debug("_init_db_client %s", self.service_cfg)

    local mongo_cfg = self.all_service_cfg:get_third_party_service(Service_Const.Mongo_Service, self.service_cfg[Service_Const.uuid_mongo_service])
    assert(mongo_cfg)
    local uuid_names = {
        [Service_Const.role_id] = true
    }
    self.db_uuid:init(
            mongo_cfg[Service_Const.Host],
            mongo_cfg[Service_Const.Auth_Db],
            mongo_cfg[Service_Const.User],
            mongo_cfg[Service_Const.Pwd],
            mongo_cfg[Service_Const.Db_name],
            mongo_cfg[Service_Const.coll_name],
            uuid_names
    )
end