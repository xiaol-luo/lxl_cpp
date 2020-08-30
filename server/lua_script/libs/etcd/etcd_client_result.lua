
---@class EtcdClientResult
---@field result_node EtcdResult
EtcdClientResult = EtcdClientResult or class("EtcdClientResult")

function EtcdClientResult:ctor()
    self._error_msg = nil
    self.op_result = nil
    self.result_node = nil
    self[Etcd_Const.Rsp_State] = nil
end

---@return boolean
function EtcdClientResult:is_ok()
    local error_msg = self:error_msg()
    if error_msg then
        return false
    end
    if self.op_result and self.op_result.errorCode and 0 ~= self.op_result.errorCode then
        return false
    end
    return true
end

function EtcdClientResult:error_msg()
    local error_msg = nil
    if self._error_msg then
        error_msg = self._error_msg
    else
        if self.op_result and self.op_result.message then
            error_msg = self.op_result.message
        end
    end
    return error_msg
end

---@param json_str string
function EtcdClientResult:prase_op_result(json_str)
    self.op_result = rapidjson.decode(json_str)
    self.result_node = EtcdResult:new()
    self.result_node:parse_from(self.op_result)
end

---@return table<string, string>
function EtcdClientResult:to_json()
    local tb = {
        error_msg = self:error_msg(),
        op_result = self.op_result,
    }
    local ret = rapidjson.encode(tb)
    return ret
end

