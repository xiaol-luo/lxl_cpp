
function GameService:_init_redis_client()
    self.module_mgr:add_module(RedisClientModule:new(self.module_mgr, "redis_client"))

    -- log_debug("_init_db_client %s", self.service_cfg)
    local redis_cfg = self.all_service_cfg:get_third_party_service(Service_Const.redis_service, self.service_cfg[Service_Const.redis_service])
    assert(redis_cfg)
    local is_cluster = 1 == tonumber(redis_cfg.is_cluster)
    self.redis_client:init(is_cluster, redis_cfg.host, redis_cfg.pwd, tonumber(redis_cfg.thread_num), tonumber(redis_cfg.cnn_timeout_ms), tonumber(redis_cfg.cmd_timeout_ms))
end