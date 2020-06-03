
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

    local ret = EtcdResult.parse(full_data)

    log_print("+++++++++++++++++++reset+++++++++++++++++++++++++")
    log_print("full_data", full_data)
    log_print("---------------------------------------------")
    log_print("EtcdWatchResult:reset ", ret)
    log_print("!!!!!!!!!!!!!!!!!!!reset!!!!!!!!!!!!!!!!!!!!!!!!!!!")

end

---@param change_data EtcdClientResult
function EtcdWatchResult:apply_change(change_data)
    local ret = EtcdResult.parse(change_data)

    log_print("+++++++++++++++++apply_change+++++++++++++++++++++++++++")
    log_print("apply_change full data", change_data)
    log_print("---------------------------------------------")
    log_print("EtcdWatchResult:apply_change ", ret)
    log_print("!!!!!!!!!!!!!!!!!!!!apply_change!!!!!!!!!!!!!!!!!!!!!!!!!!")
end

