
EtcdClientResult = EtcdClientResult or class("EtcdClientResult")

function EtcdClientResult:ctor()
    self.fail_event = nil
    self.fail_code = 0
    self.op_result = nil
end

function EtcdClientResult:prase_op_result(json_str)
    self.op_result = rapidjson.decode(json_str)
end

function EtcdClientResult:to_json()
    local tb = {
        fail_event = self.fail_event,
        fail_code = self.fail_code,
        op_result = self.op_result,
    }
    local ret = rapidjson.encode(tb)
    return ret
end

