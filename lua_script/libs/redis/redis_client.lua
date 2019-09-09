
RedisClient = RedisClient or class("RedisClient")

function RedisClient:ctor(is_cluster, hosts, usr, pwd, thread_num, cnn_timeout_ms, cmd_timeout_ms)
    self.is_cluster = is_cluster
    self.hosts = hosts
    self.usr = usr
    self.pwd = pwd
    self.thread_num = thread_num
    self.cnn_timeout_ms = cnn_timeout_ms
    self.cmd_timeout_ms = cmd_timeout_ms
    self.redis_task_mgr = native.RedisTaskMgr:new()
end

function RedisClient:start()
    self:stop()
    local ret = self.redis_task_mgr:start(self.is_cluster, self.hosts, self.usr, self.pwd,
            self.thread_num, self.cnn_timeout_ms, self.cmd_timeout_ms)
    return ret
end

function RedisClient:stop()
    self.redis_task_mgr:stop()
end

function RedisClient:on_tick()
    self.redis_task_mgr:on_frame()
end

function RedisClient:command(hash_code, cb_fn, fmt_str, ...)
    local cmd_str = string.format(fmt_str, ...)
    self.redis_task_mgr:command(hash_code, cb_fn, cmd_str)
end

function RedisClient:array_command()

end

function RedisClient:binary_command()

end

