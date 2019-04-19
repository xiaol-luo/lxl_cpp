
TimerProxy = TimerProxy or class("TimerProxy")

function TimerProxy:ctor()
    self.timer_ids = {}
end

function TimerProxy:next(fn, start_ms)
    local timer_id = timer_next(fn, start_ms)
    self.timer_ids[timer_id] = true
    return timer_id
end

function TimerProxy:add(fn, execute_span_ms, execute_times)
    local timer_id = timer_add(fn, execute_span_ms, execute_times)
    self.timer_ids[timer_id] = true
    return timer_id
end

function TimerProxy:firm(fn, execute_span_ms, execute_times)
    local timer_id = timer_firm(fn, execute_span_ms, execute_times)
    self.timer_ids[timer_id] = true
    return timer_id
end

function TimerProxy:remove(timer_id)
    if self.timer_ids[timer_id] then
        self.timer_ids[timer_id] = nil
        timer_remove(timer_id)
    end
end

function TimerProxy:release_all()
    local timer_ids = self.timer_ids
    self.timer_ids = {}
    for id, _ in pairs(timer_ids) do
        timer_remove(id)
    end
end

