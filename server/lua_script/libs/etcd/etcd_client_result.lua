
---@class EtcdClientResult
EtcdClientResult = EtcdClientResult or class("EtcdClientResult")

function EtcdClientResult:ctor()
    self.fail_event = nil
    self.fail_code = 0
    self.op_result = nil
    self.result_node = nil
    self[Etcd_Const.Rsp_State] = nil
end

---@return boolean
function EtcdClientResult:is_ok()
    local fail_msg = self:fail_msg()
    if 0 ~= self.fail_code then
        return false
    end
    if self.op_result and self.op_result.errorCode and 0 ~= self.op_result.errorCode then
        return false
    end
    return true
end

function EtcdClientResult:fail_msg()
    local fail_msg = nil
    if self.fail_event then
        fail_msg = self.fail_event
    else
        if self.op_result and self.op_result.message then
            fail_msg = self.op_result.message
        end
    end
    return fail_msg
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
        fail_event = self.fail_event,
        fail_code = self.fail_code,
        op_result = self.op_result,
    }
    local ret = rapidjson.encode(tb)
    return ret
end

