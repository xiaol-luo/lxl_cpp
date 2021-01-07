
---@class TimerProxy
TimerProxy = TimerProxy or class("TimerProxy")

function TimerProxy:ctor()
    self.timer_ids = {}
end

function TimerProxy:add(fn, delay_sec, execute_span_sec, execute_times)
    local timer_id = timer_add(fn, delay_sec, execute_span_sec, execute_times)
    self.timer_ids[timer_id] = true
    return timer_id
end

function TimerProxy:firm(fn, execute_span_sec, execute_times)
    local timer_id = timer_firm(fn, execute_span_sec, execute_times)
    self.timer_ids[timer_id] = true
    return timer_id
end

function TimerProxy:delay(fn, delay_sec)
    local timer_id = timer_delay(fn, delay_sec)
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

