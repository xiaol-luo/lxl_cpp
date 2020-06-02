
---@class EtcdWatchResultVisitor
EtcdWatchResultVisitor = EtcdWatchResultVisitor or class("EtcdWatchResultVisitor")

function EtcdWatchResultVisitor:ctor(watch_path)
    self.watch_path = watch_path
    self.result = nil
    self.result_diff = nil
end

---@param full_data EtcdClientResult
function EtcdWatchResultVisitor:reset(full_data)

end

---@param change_data EtcdClientResult
function EtcdWatchResultVisitor:apply_change(change_data)

end

