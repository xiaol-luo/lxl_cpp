
---@class EtcdResult
EtcdResult = EtcdResult or class("EtcdResult")

function EtcdResult:ctor()
    self.etcd_index = nil
    self.action = nil
    self.node = nil
    self.error_code = nil
end

function EtcdResult:parse_from(op_result)
    if not op_result then
        return false
    end
    self.action = op_result[Etcd_Const.Action]
    local etcd_idx = op_result[Etcd_Const.Head_Index]
    if etcd_idx then
        self.etcd_index = tonumber(op_result[Etcd_Const.Head_Index])
    end
    local error_code = op_result[Etcd_Const.ErrorCode]
    if error_code then
        self.error_code = tonumber(error_code)
    end
    local force_as_node = (Etcd_Const.Get ~= self.action)
    self.node = parse_etcd_result_node(op_result.node, force_as_node)
    return nil ~= self.node
end

function EtcdResult.parse(op_result)
    local ret = EtcdResult:new()
    local is_ok = ret:parse_from(op_result)
    return is_ok and ret or nil
end

