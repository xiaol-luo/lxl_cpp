
RedisClientModule = RedisClientModule or class("RedisClientModule", ServiceModule)

function RedisClientModule:ctor(module_mgr, module_name)
    RedisClientModule.super.ctor(self, module_mgr, module_name)
    self.redis_client = nil
end

function RedisClientModule:init(is_cluster, hosts, pwd, thread_num, cnn_timeout_ms, cmd_timeout_ms)
    RedisClientModule.super.init(self)
    self.redis_client = RedisClient:new(is_cluster, hosts, pwd, thread_num, cnn_timeout_ms, cmd_timeout_ms)
end

function RedisClientModule:start()
    self.curr_state = Service_State.Starting
    local ret = self.redis_client:start()
    if not ret then
        self.error_num = 1
        self.error_msg = "start fail"
    else
        self.curr_state = Service_State.Started
    end
end

function RedisClientModule:stop()
    self.curr_state = Service_State.Stopped
    self.redis_client:stop()
end

function RedisClientModule:on_update()
    self.redis_client:on_tick()
end


function RedisClientModule:command(hash_code, cb_fn, fmt_str, ...)
    return self.redis_client:command(hash_code, cb_fn, fmt_str, ...)
end

function RedisClientModule:array_command(hash_code, cb_fn, cmd_list)
    return self.redis_client:array_command(hash_code, cb_fn, cmd_list)
end

function RedisClientModule:binary_command(hash_code, cb_fn, fmt_str, ...)
    return self.redis_client:binary_command(hash_code, cb_fn, fmt_str, ...)
end

function RedisClientModule:co_command(hash_code, fmt_str, ...)
    return self.redis_client:co_command(hash_code, fmt_str, ...)
end


function RedisClientModule:co_array_command(hash_code, cmd_list)
    return self.redis_client:co_array_command(hash_code, cmd_list)
end

function RedisClientModule:co_binary_command(hash_code, fmt_str, ...)
    return self.redis_client:co_binary_command(hash_code, fmt_str, ...)
end





