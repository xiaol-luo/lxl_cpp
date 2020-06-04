
---@class EtcdWatchResult: EventMgr
---@field watch_path string
---@field result table<string, EtcdResultNode>
---@field result_diff table<number, string>
EtcdWatchResult = EtcdWatchResult or class("EtcdWatchResult", EventMgr)

function EtcdWatchResult:ctor(watch_path)
    EtcdWatchResult.super.ctor(self)
    self.watch_path = watch_path
    self.result = {}
    self.result_diff = {}
    self._is_result_diff_dirty = false
end

---@param full_data EtcdClientResult
function EtcdWatchResult:reset(full_data)
    local etcd_result = EtcdResult.parse(full_data)
    local old_result = self.result
    self.result = {}
    self.result_diff = {}

    for _, node in EtcdResultNodeVisitor:new(etcd_result.node):iter_node() do
        self.result[node.key] = node
        if old_result[node.key] then
            self:_add_result_diff(Etcd_Watch_Result_Diff.Update, node.key, node)
        else
            self:_add_result_diff(Etcd_Watch_Result_Diff.Add, node.key, node)
        end
        old_result[node.key] = nil -- 这个没必要加入后续比较了
    end
    for _, node in pairs(old_result) do
        self:_add_result_diff(Etcd_Watch_Result_Diff.Delete, node.key, nil)
    end
    self:_fire_result_diff()
end

function EtcdWatchResult:_add_result_diff(result_diff, key, new_val)
    self._is_result_diff_dirty = true
    table.insert(self.result_diff, {
        result_diff = result_diff,
        key = key,
        new_val = new_val,
    })
end

function EtcdWatchResult:_fire_result_diff()
    if not self._is_result_diff_dirty then
        return false
    end
    self._is_result_diff_dirty = false
    for _, v in pairs(self.result_diff) do
        self:fire(Etcd_Watch_Event.watch_result_diff, v.key, v.result_diff, v.new_val)
    end
    self:fire(Etcd_Watch_Event.watch_result_change, self)
end

---@param change_data EtcdClientResult
function EtcdWatchResult:apply_change(change_data)
    local etcd_ret = EtcdResult.parse(change_data)
    self.result_diff = {}

    local is_handle = false
    if Etcd_Const.Delete == etcd_ret.action or Etcd_Const.Expire == etcd_ret.action then
        is_handle = true
        if etcd_ret.node.is_dir then
            local remove_node_key = {}
            for key, node in pairs(self.result) do
                if 1 == string.find(key, etcd_ret.node.key) then
                    table.insert(remove_node_key, { key=key, node=node })
                end
            end
            for _, v in pairs(remove_node_key) do
                self.result[v.key] = nil
                self:_add_result_diff(Etcd_Watch_Result_Diff.Delete, v.key, v.node)
            end
        else
            self.result[etcd_ret.node.key] = nil
            self:_add_result_diff(Etcd_Watch_Result_Diff.Delete, etcd_ret.node.key, etcd_ret.node)
        end
    end
    if Etcd_Const.Update == etcd_ret.action or Etcd_Const.Set == etcd_ret.action then
        is_handle = true
        if not etcd_ret.node.is_dir then
            self.result[etcd_ret.node.key] = etcd_ret.node
            self:_add_result_diff(Etcd_Watch_Result_Diff.Update, etcd_ret.node.key, etcd_ret.node)
        end
    end
    if not is_handle then
        log_error("EtcdWatchResult:apply_change not handle action type %s", etcd_ret.action, etcd_ret)
    end

    self:_fire_result_diff()
end

