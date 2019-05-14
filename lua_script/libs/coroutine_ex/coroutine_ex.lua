--[[
    这里的写是CoroutineEx，其实更像是个线程，后续可能会改名。实现这个类，主要是想把异步的调用方便地换成同步的写法。
    此类有以下约定：
    1.我把此类叫做线程
    1.不建议存在线程中启动新的线程
    2.yield函数只能在其归属的线程的函数内调用 （可阅读代码）
    3.start函数只能调用一次，且并不会阻塞，马上返回start结果给调用函数。（wrap_main_logic配合做了处理）
    4.resume函数只能对处理 started && can_resume后的线程（do_start 做了处理）
    5.这个线程销毁的时候，会执行over_cb回调函数。
    6.main_logic能返回多个值，以这种格式{ n=num, vals=[]}，存储在return_val中。
    7.不建议使用yield返回值给resume，因为很多时候都不知道上一次resume的位置在哪（你搞得清楚其实也能用）。、
        建议yield函数永远不传参数（coroutine.resume 返回值永远忽略，因为很多时候并不特别能定位这次的yield在哪里发生）
        也就是说建议这样用
        此处：（co:yield 不要传参数)
            local co_ok, a, b = co:yield()
        别的地方：(co:resume的返回值不要用）
            co:resume("a", "b")
--]]

CoroutineEx = CoroutineEx or class("CoroutineEx")

function wrap_main_logic(main_logic)
    return function(...)
        coroutine.yield()
        local n, vals = Functional.varlen_param_info(main_logic(...))
        local co = CoroutineExMgr.get_running()
        co.return_vals = { n=n, vals=vals }
        return table.unpack(vals, 1, n)
    end
end

function CoroutineEx:ctor(main_logic, over_cb)
    self.co = coroutine.create(wrap_main_logic(main_logic))
    self.is_killed = false
    self.kill_reason = nil
    self.error_msg = nil
    self.over_cb = over_cb
    self.over_cb_done = false
    self.is_started = false
    self.can_resume = false
    self.timer_proxy = TimerProxy:new()
    self.expired_tid = nil
    self.custom_data = nil -- 用户自定义数据
    self.return_val = nil -- main_logic函数返回值 { n=num, vals=[]}
end

function CoroutineEx:expired_after_ms(ms)
    if CoroutineState.Dead == self:status() then
        return
    end
    self:cancel_expired()
    self.expired_tid = self.timer_proxy:delay(Functional.make_closure(
            CoroutineEx.kill, self, CoroutineKillReason.Expired, CoroutineKillReason.Expired) ,ms)
end

function CoroutineEx:cancel_expired()
    if self.expired_tid then
        self.timer_proxy:remove(self.expired_tid)
        self.expired_tid = nil
    end
end

function CoroutineEx:get_key()
    return self.co
end

local do_start = function(co)
    local co_ex = CoroutineExMgr.get_co(co)
    if co_ex then
        if CoroutineState.Dead ~= co_ex:status() then
            co_ex.can_resume = true
            coroutine.resume(co_ex:get_key())
        end
    end
end

function CoroutineEx:start(...)
    if self.is_started then
        return false, "already started"
    end
    if CoroutineState.Suspended ~= self:status() then
        return false, "can not resume and non-suppended coroutine"
    end
    self.is_started = true
    local is_ok = coroutine.resume(self.co, ...)
    local error_msg = nil
    if not is_ok then
        error_msg = "start self.co fail"
        self:report_error(error_msg)
    else
        CoroutineExMgr.add_delay_execute_fn(Functional.make_closure(do_start, self:get_key()))
    end
    return is_ok, error_msg
end

function CoroutineEx:resume(...)
    if not self.is_started or not self.can_resume then
        local msg = "can not resume an not started coroutine"
        self:report_error(msg)
        assert(false)
    end
    local co_status = self:status()
    if CoroutineState.Suspended ~= co_status then
        if CoroutineState.Running == co_status or CoroutineState.Normal == co_status then
            local msg = "can not resume a non-suppended coroutine"
            self:report_error(msg)
            assert(false)
        end
        if CoroutineState.Dead == co_status then
            local msg = "can not resume a dead coroutine"
            log_error(msg)
            return false, msg
        end
    end
    local n, results = Functional.varlen_param_info(coroutine.resume(self.co, true, ...))
    local is_ok = results[1]
    if not is_ok then
        local error_msg = results[2]
        self:report_error(error_msg)
    end
    return table.unpack(results, 1, n)
end

function CoroutineEx:yield(...)
    local is_ok = true
    local error_msg = nil
    local running_co = coroutine.running()
    if self.co ~= running_co then
        is_ok = false
        error_msg = "running coroutine is not equal to self.co"
    end
    if CoroutineState.Running ~= self:status() then
        is_ok = false
        error_msg = "can not yield a not running coroutine"
    end
    if not is_ok then
        self:report_error(error_msg)
        return false, error_msg
    else
        return coroutine.yield(...)
    end
end

function CoroutineEx:status()
    if self.is_killed then
        return CoroutineState.Dead
    end
    return coroutine.status(self.co)
end

function CoroutineEx:get_error_msg()
    return self.error_msg
end

function CoroutineEx:get_kill_reason()
    return self.kill_reason
end

function CoroutineEx:kill(kill_reason, error_msg)
    if not self.is_killed then
        self.kill_reason = kill_reason
        self.is_killed = true
        self.error_msg = error_msg
        log_error("coroutine_ex report_error : %s", self.error_msg or "unknown")
    end
    self:cancel_expired()
end

function CoroutineEx:report_error(error_msg)
    self:kill(CoroutineKillReason.ReportError, error_msg)
end

function CoroutineEx:trigger_over_cb()
    if CoroutineState.Dead ~= self:status() then
        return
    end
    if not self.over_cb_done then
        self.over_cb_done = true
        if IsFunction(self.over_cb) then
            self.over_cb(self)
        end
    end
end

function CoroutineEx:set_custom_data(data)
    self.custom_data = data
end

function CoroutineEx:get_custom_data()
    return self.custom_data
end

function CoroutineEx:get_return_vals()
    return self.return_vals
end
