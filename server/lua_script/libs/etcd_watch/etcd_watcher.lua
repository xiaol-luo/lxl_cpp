
---@class EtcdWatcher: EventMgr
---@field watch_path string
---@field pre_result
EtcdWatcher = EtcdWatcher or class("EtcdWatcher", EventMgr)

function EtcdWatcher:ctor(host, user, pwd, watch_path)
    EtcdWatcher.super.ctor(self)
    self._etcd_client = EtcdClient:new(host, user, pwd)
    self.watch_path = watch_path
    self.watch_result = EtcdWatchResult:new(self.watch_path)
    self._op_id = 0
    self._wait_idx = nil
    self._next_seq = make_sequence(0)
    self._last_seq = self._next_seq()
    self._tid = nil
    self._timer_proxy = TimerProxy:new()
    self._event_binder = EventBinder:new()
end

function EtcdWatcher:start()
    self:_do_watch(true)
    self._event_binder:bind(self.watch_result, Etcd_Watch_Event.watch_result_change, Functional.make_closure(self._on_watch_result_change, self))
    self._event_binder:bind(self.watch_result, Etcd_Watch_Event.watch_result_diff, Functional.make_closure(self._on_watch_result_diff, self))
end

function EtcdWatcher:stop()
    self._event_binder:release_all()
    self._timer_proxy:release_all()
    self._tid = nil
    self._last_seq = self._next_seq()
    if self._op_id then
        self._etcd_client:cancel(self._op_id)
        self._op_id = nil
    end
end

function EtcdWatcher:_do_watch(is_force_pull)
    if self._op_id then
        self._etcd_client:cancel(self._op_id)
        self._op_id = nil
    end
    if self._tid then
        self._timer_proxy:remove(self._tid)
        self._tid = nil
    end

    local is_pull_action = not self._wait_idx
    if is_force_pull then
        is_pull_action = true
        self._wait_idx = nil
    end
    local next_seq = self._next_seq()
    self._last_seq = next_seq
    if is_pull_action then
        self._etcd_client:get(self.watch_path, true, Functional.make_closure(self._process_pull_result, self, next_seq))
    else
        self._etcd_client:watch(self.watch_path, true, self._wait_idx, Functional.make_closure(self._process_watch_result, self, next_seq))
    end
end

function EtcdWatcher:_delay_do_watch()
    if self._tid then
        self._timer_proxy:remove(self._tid)
        self._tid = nil
    end
    self._tid = self._timer_proxy:delay(Functional.make_closure(self._do_watch, self, false), 250)
end

---@param ret EtcdClientResult
function EtcdWatcher:_process_pull_result(seq, op_id, op, ret)
    if seq < self._last_seq then
        return
    end
    self:_delay_do_watch()

    if ret:is_ok() then
        self._wait_idx = tonumber(ret.op_result[Etcd_Const.Head_Index]) + 1
        self.watch_result:reset(ret.op_result)
    else
        self._wait_idx = nil
    end
end

---@param ret EtcdClientResult
function EtcdWatcher:_process_watch_result(seq, op_id, op, ret)
    if seq < self._last_seq then
        return
    end
    self:_delay_do_watch()

    if ret:is_ok() then
        self._wait_idx = tonumber(ret.op_result.node.modifiedIndex) + 1
        self.watch_result:apply_change(ret.op_result)
    else
        self._wait_idx = nil
    end

    -- for test
--[[    if math.random() > 0.5 then
        self._wait_idx = nil
    end]]
end

function EtcdWatcher:_on_watch_result_change(watch_result)
    -- log_print("atcher:_on_watch_result_change")
    self:fire(Etcd_Watch_Event.watch_result_change, watch_result, self)
end

function EtcdWatcher:_on_watch_result_diff(key, result_diff_type, new_node)
    -- log_print("atcher:_on_watch_result_diff")
    self:fire(Etcd_Watch_Event.watch_result_diff, key, result_diff_type, new_node)
end




