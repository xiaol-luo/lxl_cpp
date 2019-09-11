
function GameService:_init_redis_client()
    self.module_mgr:add_module(RedisClientModule:new(self.module_mgr, "redis_client"))

    -- log_debug("_init_db_client %s", self.service_cfg)
    local redis_cfg = self.all_service_cfg:get_third_party_service(Service_Const.redis_service, self.service_cfg[Service_Const.redis_service])
    assert(redis_cfg)
    self.db_client:init(redis_cfg.is_cluster, redis_cfg.host, redis_cfg.pwd, redis_cfg.thread_num, redis_cfg.cnn_timeout_ms, redis_cfg.cmd_timeout_ms)
end