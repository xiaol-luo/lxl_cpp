
---@class EtcdWatchResult
---@field watch_path string
---@field result
---@field result_diff
EtcdWatchResult = EtcdWatchResult or class("EtcdWatchResult")

function EtcdWatchResult:ctor(watch_path)
    self.watch_path = watch_path
    self.result = {}
    self.result_diff = {}
end

---@param full_data EtcdClientResult
function EtcdWatchResult:reset(full_data)
    log_print("EtcdWatchResult:reset ", full_data)
end

---@param change_data EtcdClientResult
function EtcdWatchResult:apply_change(change_data)
    log_print("EtcdWatchResult:apply_change ", change_data)
end

