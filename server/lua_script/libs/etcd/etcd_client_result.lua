
---@class EtcdClientResult
EtcdClientResult = EtcdClientResult or class("EtcdClientResult")

function EtcdClientResult:ctor()
    self.fail_event = nil
    self.fail_code = 0
    self.op_result = nil
    self[Etcd_Const.Rsp_State] = nil
end

---@return boolean
function EtcdClientResult:is_ok()
    if 0 ~= self.fail_code then
        return false
    end
    local rsp_state = self[Etcd_Const.Rsp_State]
    if Etcd_Const.Rsp_State_OK ~= rsp_state and
            Etcd_Const.Rsp_State_Created ~= rsp_state then
        return false
    end
    return true
end

---@param json_str string
function EtcdClientResult:prase_op_result(json_str)
    self.op_result = rapidjson.decode(json_str)
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

