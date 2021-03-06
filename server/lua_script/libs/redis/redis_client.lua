
---@class RedisClient
RedisClient = RedisClient or class("RedisClient")

function RedisClient:ctor(is_cluster, hosts, pwd, thread_num, cnn_timeout_ms, cmd_timeout_ms)
    self.is_cluster = is_cluster
    self.hosts = hosts
    self.pwd = pwd
    self.thread_num = thread_num
    self.cnn_timeout_ms = cnn_timeout_ms
    self.cmd_timeout_ms = cmd_timeout_ms
    self.redis_task_mgr = native.RedisTaskMgr:new()
    self.timer_proxy = TimerProxy:new()
end

function RedisClient:start()
    self:stop()
    local ret = self.redis_task_mgr:start(self.is_cluster, self.hosts, self.pwd, self.thread_num, self.cnn_timeout_ms, self.cmd_timeout_ms)
    if ret then
        self.timer_proxy:firm(Functional.make_closure(self.on_tick, self), 200, Forever_Execute_Timer)
    end
    return ret
end

function RedisClient:stop()
    self.timer_proxy:release_all()
    self.redis_task_mgr:stop()
end

function RedisClient:on_tick()
    self.redis_task_mgr:on_frame()
end

function RedisClient:_co_call_help(fn, hash_code, ...)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    return fn(self, hash_code, new_coroutine_callback(co), ...)
end

local make_closure_wrap_redis_command_callback = function(cb_fn)
    local fn = nil
    if is_function(cb_fn) then
        fn = function(ret)
            local redis_result = RedisResult:new(ret)
            cb_fn(redis_result)
        end
    end
    return fn
end

---@param cb_fn Fn_RedisCommandCb
function RedisClient:command(hash_code, cb_fn, fmt_str, ...)
    -- 如果命令前边有空格，hiredis_vip会分析命令失败
    local cmd_str = string.format(fmt_str, ...)
    return self.redis_task_mgr:command(hash_code, make_closure_wrap_redis_command_callback(cb_fn), string.ltrim(cmd_str, " "))
end

function RedisClient:co_command(hash_code, fmt_str, ...)
    return self:_co_call_help(self.command, hash_code, fmt_str, ...)
end

---@param cb_fn Fn_RedisCommandCb
---@return number
function RedisClient:array_command(hash_code, cb_fn, cmd_list)
    if not cmd_list or #cmd_list <= 0 then
        return 0
    end
    local input_cmds = {}
    for i, cmd in ipairs(cmd_list) do
        if not is_string(cmd) then
            table.insert(input_cmds, tostring(cmd))
        else
            if 1 == i then -- 如果命令前边有空格，hiredis_vip会分析命令失败
                table.insert(input_cmds, string.ltrim(cmd, " "))
            else
                table.insert(input_cmds, cmd)
            end
        end
    end
    return self.redis_task_mgr:array_command(hash_code, make_closure_wrap_redis_command_callback(cb_fn), input_cmds)
end

function RedisClient:co_array_command(hash_code, cmd_list)
    return self:_co_call_help(self.array_command, hash_code, cmd_list)
end

---@param cb_fn Fn_RedisCommandCb
---@return number
function RedisClient:binary_command(hash_code, cb_fn, fmt_str, ...)
    local t_len, t = Functional.varlen_param_info(...)
    if t_len <= 0 then
        return self:command(hash_code, cb_fn, fmt_str)
    else
        local input_cmds = {}
        for _, cmd in ipairs(t) do
            if not is_string(cmd) then
                table.insert(input_cmds, tostring(cmd))
            else
                table.insert(input_cmds, cmd)
            end
        end
        -- 如果命令前边有空格，hiredis_vip会分析命令失败
        return self.redis_task_mgr:binary_command(hash_code, make_closure_wrap_redis_command_callback(cb_fn), string.ltrim(fmt_str, " "), input_cmds)
    end
end

function RedisClient:co_binary_command(hash_code, fmt_str, ...)
    return self:_co_call_help(self.binary_command, hash_code, fmt_str, ...)
end

