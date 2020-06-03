
---@class EtcdResultBase
EtcdResultBase = EtcdResultBase or class("EtcdResultBase")

function EtcdResultBase:ctor(result_type)
    self.result_type = result_type
    self.create_index = nil
    self.modify_index = nil
    self.key = nil
    self.value = nil
end

function EtcdResultBase:reset()
    self.create_index = nil
    self.modify_index = nil
end

function EtcdResultBase:parse_from(op_result)

end

function EtcdResultBase:is_dir()
    return Etcd_Result_Type.dir == self.result_type
end

